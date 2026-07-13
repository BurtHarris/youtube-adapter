@{
    Severity     = @('Error', 'Warning', 'Information')

    ExcludeRules = @(
        # Sample module has no state-changing functions; remove if yours does.
        'PSUseShouldProcessForStateChangingFunctions'
    )

    Rules        = @{
        PSUseConsistentIndentation = @{
            Enable          = $true
            IndentationSize = 4
            Kind            = 'space'
        }
        PSUseConsistentWhitespace  = @{
            Enable         = $true
            CheckOpenBrace = $true
            CheckOpenParen = $true
            # CheckOperator conflicts with aligned hashtable assignments (PSAlignAssignmentStatement)
            CheckOperator  = $false
            CheckSeparator = $true
        }
        PSAlignAssignmentStatement = @{
            Enable         = $true
            CheckHashtable = $true
        }
        PSPlaceOpenBrace           = @{
            Enable     = $true
            OnSameLine = $true
        }
        PSPlaceCloseBrace          = @{
            Enable = $true
        }
        PSAvoidUsingCmdletAliases  = @{
            Enable = $true
        }
    }
}
