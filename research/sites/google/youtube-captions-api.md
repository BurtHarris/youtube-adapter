# YouTube Data API v3 — Captions API Research

**Research date**: 2026-07-13
**Budget used**: ~15 min, 4 documents, depth 1
**Question**: Can YouTube Data API v3 deliver usable plain-text transcripts for videos in an authenticated user's playlists?

---

## Budget log

| Budget | Limit | Used |
|--------|-------|------|
| `time_budget_minutes` | 15 | ~15 |
| `document_budget` | 8 | 4 |
| `depth_budget` | 1 | 1 |

Sources consulted:
1. https://developers.google.com/youtube/v3/docs/ (API reference index)
2. https://developers.google.com/youtube/v3/docs/captions (resource overview)
3. https://developers.google.com/youtube/v3/docs/captions/list
4. https://developers.google.com/youtube/v3/docs/captions/download

---

## 1. What the Captions API returns

### `captions.list` — metadata only

`GET https://www.googleapis.com/youtube/v3/captions`
Source: https://developers.google.com/youtube/v3/docs/captions/list

Returns a `youtube#captionListResponse` containing an array of `caption` resources. **The API response does not contain the actual captions.** Each caption resource carries only metadata:

| Field | Type | Notes |
|-------|------|-------|
| `id` | string | Caption track ID — required to call `captions.download` |
| `snippet.videoId` | string | Associated video |
| `snippet.trackKind` | string | `ASR` (auto-speech-recognition), `forced`, or `standard` (manual) |
| `snippet.language` | string | BCP-47 language tag |
| `snippet.name` | string | Display name (≤150 chars) |
| `snippet.audioTrackType` | string | `primary`, `commentary`, `descriptive`, `unknown` |
| `snippet.isCC` | boolean | Closed-captions flag |
| `snippet.isDraft` | boolean | True = not publicly visible |
| `snippet.isAutoSynced` | boolean | Whether YouTube synced timing |
| `snippet.status` | string | `failed`, `serving`, `syncing` |

Quota cost: **50 units** per call.
Source: https://developers.google.com/youtube/v3/docs/captions/list

### `captions.download` — binary caption file

`GET https://www.googleapis.com/youtube/v3/captions/{id}`
Source: https://developers.google.com/youtube/v3/docs/captions/download

Returns a **binary file** (`Content-Type: application/octet-stream`). The format is the track's original format unless `tfmt` is specified.

**`tfmt` supported values** (all are timed-text formats with timestamps):

| Value | Format |
|-------|--------|
| `sbv` | SubViewer subtitle |
| `scc` | Scenarist Closed Caption |
| `srt` | SubRip subtitle |
| `ttml` | Timed Text Markup Language (XML) |
| `vtt` | Web Video Text Tracks |

The `tlang` parameter requests machine translation (Google Translate) to an ISO 639-1 language code.

Quota cost: **200 units** per call.
Source: https://developers.google.com/youtube/v3/docs/captions/download

---

## 2. OAuth scopes required

Both `captions.list` and `captions.download` require OAuth 2.0 with **at least one** of:

- `https://www.googleapis.com/auth/youtube.force-ssl`
- `https://www.googleapis.com/auth/youtubepartner`

An API key alone is **not sufficient**; a user OAuth token is required.
Source: https://developers.google.com/youtube/v3/docs/captions/list, https://developers.google.com/youtube/v3/docs/captions/download

---

## 3. Convertibility to plain text

All five `tfmt` formats are timed-text: each line of spoken content is associated with timestamp metadata. Conversion to plain text requires stripping timestamps and tags, but the spoken content is fully present in each format.

- **`srt`** and **`vtt`**: line-oriented text with timestamp headers — straightforward to strip with a regex or parser; no structural information is lost from the transcript perspective.
- **`ttml`**: XML with `<p>` elements and `begin`/`end` attributes — parseable with any XML library.
- **`sbv`**: similar to SRT; timestamps on dedicated lines.
- **`scc`**: Scenarist binary-encoded captions — requires a dedicated decoder; not straightforwardly human-readable.

**Verdict**: `srt` or `vtt` format yields usable plain text with minimal effort. No significant content loss for a transcript use case.

---

## 4. Gaps and limitations

### 4a. Critical: edit-permission requirement on `captions.download`

> "This method requires the user to have permission to **edit the video**."
> Source: https://developers.google.com/youtube/v3/docs/captions/download

The authenticated user must be the **video owner** (or acting via `onBehalfOfContentOwner` for a CMS/content-partner account). A regular user OAuth token cannot download captions for videos they do not own, even if the captions are publicly visible during playback.

This means: **captions for third-party videos in a user's playlist are inaccessible via this API**, regardless of caption visibility.

Error returned for non-owners:
```
403 forbidden — "The permissions associated with the request are not sufficient to download the caption track."
```
Source: https://developers.google.com/youtube/v3/docs/captions/download

### 4b. Auto-generated (ASR) vs. manual captions

`captions.list` distinguishes them via `snippet.trackKind`:
- `ASR` = auto-generated via speech recognition
- `standard` = manually uploaded

Both types appear in the list response. The API does not document any restriction on downloading ASR vs. manual tracks for the video owner specifically, but the edit-permission requirement applies to both.
Source: https://developers.google.com/youtube/v3/docs/captions

### 4c. Videos with no captions

If a video has no caption tracks, `captions.list` returns an empty `items` array. There is no fallback or auto-generation-on-demand endpoint in the Data API.
Source: https://developers.google.com/youtube/v3/docs/captions/list

### 4d. Draft tracks

Tracks with `snippet.isDraft = true` are not publicly visible. The download endpoint will attempt to return them for authorized owners; behavior for non-owners is not explicitly documented beyond the `forbidden` error.
Source: https://developers.google.com/youtube/v3/docs/captions

### 4e. Quota cost

A workflow that lists then downloads captions per video costs a minimum of **50 + 200 = 250 quota units per video**. The default daily quota is 10,000 units, yielding a maximum of ~40 videos per day at this rate.
Source: https://developers.google.com/youtube/v3/docs/captions/list, https://developers.google.com/youtube/v3/docs/captions/download

---

## 5. Other Data API v3 resources with transcript-like content

The full API reference was reviewed (https://developers.google.com/youtube/v3/docs/). The following resource types exist:

Activities, Captions, ChannelBanners, ChannelSections, Channels, CommentThreads, Comments, I18nLanguages, I18nRegions, Members, MembershipsLevels, PlaylistItems, Playlists, Search, Subscriptions, Thumbnails, VideoAbuseReportReasons, VideoCategories, Videos, Watermarks.

**No other resource provides transcript or caption text.** The `videos` resource (`videos.list`) returns metadata, statistics, content details, and player information — but no spoken-word content. There is no `transcripts` resource.
Source: https://developers.google.com/youtube/v3/docs/

---

## 6. Recommendation

**Reframe needed.**

The Captions API is technically capable of delivering plain-text transcripts when the authenticated user is the **video owner**:

1. Call `captions.list?videoId={id}&part=id,snippet` → get caption track IDs
2. Call `captions.download?id={trackId}&tfmt=srt` → get SRT file
3. Strip timestamps → plain text transcript

However, for **videos in a user's playlist that the user does not own** (the typical case for a playlist-based transcript retrieval tool), `captions.download` returns HTTP 403. The edit-permission requirement is not a quota or rate limit — it is a hard authorization boundary documented in the API.

**The stated MVP goal ("retrieve plain-text transcripts for videos in an authenticated user's playlists") is not achievable with YouTube Data API v3 alone unless the user owns all videos in those playlists.**

Alternative approaches outside the documented Data API v3 (not researched here per budget/scope):
- YouTube's `timedtext` service used by the player (not a documented API endpoint)
- YouTube Studio's export feature (not an API)
- Third-party libraries (yt-dlp, youtube-transcript-api) that reverse-engineer player requests
