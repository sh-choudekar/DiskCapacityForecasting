@{
    # Exclude rules we intentionally violate (e.g., console status output)
    ExcludeRules = @('PSAvoidUsingWriteHost')

    Rules = @{
        PSUseConsistentIndentation = @{
            Enable = $true
            IndentationSize = 2
            IndentationKind = 'space'  # 'space' or 'tab'
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
        }
        PSUseConsistentWhitespace = @{
            Enable = $true
            CheckInnerBrace = $true
            CheckOpenBrace   = $true
            CheckOpenParen   = $true
            CheckOperator    = $true
            CheckSeparator   = $true
            CheckPipe        = $true
        }
        PSAlignAssignmentStatement = @{
            Enable = $true
        }
        PSPlaceOpenBrace = @{
            Enable = $true
            OnSameLine = $true
            NewLineAfter = $true
            IgnoreOneLineBlock = $true
        }
        PSPlaceCloseBrace = @{
            Enable = $true
            NewLineAfter = $true
            IgnoreOneLineBlock = $true
        }
        PSAvoidTrailingWhitespace = @{
            Enable = $true
        }
        PSUseCorrectCasing = @{
            Enable = $true
        }
    }

    Severity = @{
        PSUseConsistentIndentation = 'Warning'
        PSUseConsistentWhitespace  = 'Warning'
        PSAlignAssignmentStatement = 'Information'
        PSPlaceOpenBrace           = 'Information'
        PSPlaceCloseBrace          = 'Information'
        PSAvoidTrailingWhitespace  = 'Warning'
        PSUseCorrectCasing         = 'Warning'
    }
}
