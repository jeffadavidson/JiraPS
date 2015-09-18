function ConvertTo-JiraField
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
                   Position = 0,
                   ValueFromPipeline = $true)]
        [PSObject[]] $InputObject,

        [ValidateScript({Test-Path $_})]
        [String] $ConfigFile,

        [Switch] $ReturnError
    )

    process
    {
        foreach ($i in $InputObject)
        {
#            Write-Debug "[ConvertTo-JiraField] Processing object: '$i'"

            if ($i.errorMessages)
            {
#                Write-Debug "[ConvertTo-JiraField] Detected an errorMessages property. This is an error result."

                if ($ReturnError)
                {
#                    Write-Debug "[ConvertTo-JiraField] Outputting details about error message"
                    $props = @{
                        'ErrorMessages' = $i.errorMessages;
                    }

                    $result = New-Object -TypeName PSObject -Property $props
                    $result.PSObject.TypeNames.Insert(0, 'PSJira.Error')

                    Write-Output $result
                }
            } else {
                $server = ($InputObject.self -split 'rest')[0]
                $http = "${server}browse/$($i.key)"

#                Write-Debug "[ConvertTo-JiraField] Defining standard properties"
                $props = @{
                    'ID' = $i.id;
                    'Name' = $i.name;
                    'Custom' = [System.Convert]::ToBoolean($i.custom);
                    'Orderable' = [System.Convert]::ToBoolean($i.orderable);
                    'Navigable' = [System.Convert]::ToBoolean($i.navigable);
                    'Searchable' = [System.Convert]::ToBoolean($i.searchable);
                    'ClauseNames' = $i.clauseNames;
                    'Schema' = $i.schema;
                }

#                Write-Debug "[ConvertTo-JiraField] Creating PSObject out of properties"
                $result = New-Object -TypeName PSObject -Property $props

#                Write-Debug "[ConvertTo-JiraField] Inserting type name information"
                $result.PSObject.TypeNames.Insert(0, 'PSJira.Field')

#                Write-Debug "[ConvertTo-JiraField] Inserting custom toString() method"
                $result | Add-Member -MemberType ScriptMethod -Name "ToString" -Force -Value {
                    Write-Output "$($this.Name)"
                }

#                Write-Debug "[ConvertTo-JiraField] Outputting object"
                Write-Output $result
            }
        }
    }

    end
    {
        Write-Debug "[ConvertTo-JiraField] Complete"
    }
}


