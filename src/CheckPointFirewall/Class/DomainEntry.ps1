# Helper Function to Parse String Representations
function ParseStringToPSCustomObject($string) {
    try {
        if (-not $string) {
            throw "Input string is null or empty."
        }

        $string = $string.TrimStart('@{').TrimEnd('}')
        $pairs = $string -split '; '
        $hashtable = @{}
        foreach ($pair in $pairs) {
            if ($pair -match '=') {
                $kv = $pair -split '=', 2
                $key = $kv[0].Trim()
                $value = $kv[1].Trim()
                $hashtable[$key] = $value
            } else {
                throw "Invalid key-value pair in string: '$pair'"
            }
        }
        return [PSCustomObject]$hashtable
    } catch {
        Write-Error "Error parsing string to PSCustomObject: $_"
        return $null
    }
}

# TimeInfo Class
class TimeInfo {
    [Int64] $Posix
    [string] $Iso8601

    TimeInfo() {}

    TimeInfo([object] $obj) {
        try {
            if (-not $obj) {
                throw "TimeInfo object is null."
            }
            $this.Posix = [Int64]$obj.posix
            $this.Iso8601 = [string]$obj.'iso-8601'
        } catch {
            Write-Error "Error initializing TimeInfo: $_"
        }
    }
}

# MetaInfo Class
class MetaInfo {
    [string] $Lock
    [string] $ValidationState
    [TimeInfo] $LastModifyTime
    [string] $LastModifier
    [TimeInfo] $CreationTime
    [string] $Creator

    MetaInfo() {}

    MetaInfo([object] $obj) {
        try {
            if (-not $obj) {
                throw "MetaInfo object is null."
            }
            $this.Lock = [string]$obj.lock
            $this.ValidationState = [string]$obj.'validation-state'

            if ($obj.'last-modify-time' -and $obj.'last-modify-time' -isnot [string]) {
                $this.LastModifyTime = [TimeInfo]::new($obj.'last-modify-time')
            }

            $this.LastModifier = [string]$obj.'last-modifier'

            if ($obj.'creation-time' -and $obj.'creation-time' -isnot [string]) {
                $this.CreationTime = [TimeInfo]::new($obj.'creation-time')
            }

            $this.Creator = [string]$obj.creator
        } catch {
            Write-Error "Error initializing MetaInfo: $_"
        }
    }
}

# Domain Class
class Domain {
    [string] $Uid
    [string] $Name
    [string] $DomainType

    Domain() {}

    Domain([object] $obj) {
        try {
            if (-not $obj) {
                throw "Domain object is null."
            }
            $this.Uid = [string]$obj.uid
            $this.Name = [string]$obj.name
            $this.DomainType = [string]$obj.'domain-type'
        } catch {
            Write-Error "Error initializing Domain: $_"
        }
    }
}

# Server Class
class Server {
    [string] $Name
    [string] $Type
    [string] $IPv4Address
    [string] $MultiDomainServer
    [bool] $Active

    Server() {}

    Server([object] $obj) {
        try {
            if (-not $obj) {
                throw "Server object is null."
            }
            $this.Name = [string]$obj.name
            $this.Type = [string]$obj.type
            $this.IPv4Address = [string]$obj.'ipv4-address'
            $this.MultiDomainServer = [string]$obj.'multi-domain-server'
            $this.Active = [bool]$obj.active
        } catch {
            Write-Error "Error initializing Server: $_"
        }
    }
}

# GlobalDomainAssignment Class
class GlobalDomainAssignment {
    [string] $Uid
    [string] $Type
    [Domain] $Domain
    [string] $GlobalDomain
    [string] $GlobalAccessPolicy
    [string] $AssignmentStatus
    [TimeInfo] $AssignmentUpToDate
    [string] $Comments
    [string] $Color
    [string] $Icon
    [string[]] $Tags
    [MetaInfo] $MetaInfo
    [bool] $ReadOnly

    GlobalDomainAssignment() {}

    GlobalDomainAssignment([object] $obj) {
        try {
            if (-not $obj) {
                throw "GlobalDomainAssignment object is null."
            }
            $this.Uid = [string]$obj.uid
            $this.Type = [string]$obj.type

            # Handle 'domain' field
            if ($obj.domain -is [string]) {
                $parsedDomain = ParseStringToPSCustomObject $obj.domain
                if ($parsedDomain) {
                    $this.Domain = [Domain]::new($parsedDomain)
                } else {
                    Write-Warning "Domain parsing failed for GlobalDomainAssignment UID $($this.Uid)"
                }
            } elseif ($obj.domain -is [object]) {
                $this.Domain = [Domain]::new($obj.domain)
            }

            $this.GlobalDomain = [string]$obj.'global-domain'
            $this.GlobalAccessPolicy = [string]$obj.'global-access-policy'
            $this.AssignmentStatus = [string]$obj.'assignment-status'

            # Handle 'assignment-up-to-date' field
            if ($obj.'assignment-up-to-date' -is [string]) {
                $parsedTime = ParseStringToPSCustomObject $obj.'assignment-up-to-date'
                if ($parsedTime) {
                    $this.AssignmentUpToDate = [TimeInfo]::new($parsedTime)
                } else {
                    Write-Warning "AssignmentUpToDate parsing failed for GlobalDomainAssignment UID $($this.Uid)"
                }
            } elseif ($obj.'assignment-up-to-date' -is [object]) {
                $this.AssignmentUpToDate = [TimeInfo]::new($obj.'assignment-up-to-date')
            }

            $this.Comments = [string]$obj.comments
            $this.Color = [string]$obj.color
            $this.Icon = [string]$obj.icon

            if ($obj.tags -is [string[]]) {
                $this.Tags = $obj.tags
            } else {
                $this.Tags = @()
            }

            # Handle 'meta-info' field
            if ($obj.'meta-info' -is [string]) {
                $parsedMetaInfo = ParseStringToPSCustomObject $obj.'meta-info'
                if ($parsedMetaInfo) {
                    $this.MetaInfo = [MetaInfo]::new($parsedMetaInfo)
                } else {
                    Write-Warning "MetaInfo parsing failed for GlobalDomainAssignment UID $($this.Uid)"
                }
            } elseif ($obj.'meta-info' -is [object]) {
                $this.MetaInfo = [MetaInfo]::new($obj.'meta-info')
            }

            $this.ReadOnly = [bool]$obj.'read-only'
        } catch {
            Write-Error "Error initializing GlobalDomainAssignment: $_"
        }
    }
}

# DomainEntry Class
class DomainEntry {
    [string] $Uid
    [string] $Name
    [string] $Type
    [Domain] $Domain
    [GlobalDomainAssignment[]] $GlobalDomainAssignments
    [string] $DomainType
    [Server[]] $Servers
    [string] $Comments
    [string] $Color
    [string] $Icon
    [string[]] $Tags
    [MetaInfo] $MetaInfo
    [bool] $ReadOnly

    [string] $ManagementServerIP

    DomainEntry () {}

    DomainEntry ([object] $obj) {
        try {
            if (-not $obj) {
                throw "DomainEntry data is null."
            }
            $this.Uid = [string]$obj.uid
            $this.Name = [string]$obj.name
            $this.Type = [string]$obj.type

            # Initialize 'domain' field
            if ($obj.domain -is [PSCustomObject]) {
                $this.Domain = [Domain]::new($obj.domain)
            } elseif ($obj.domain -is [string]) {
                $parsedDomain = ParseStringToPSCustomObject $obj.domain
                if ($parsedDomain) {
                    $this.Domain = [Domain]::new($parsedDomain)
                } else {
                    Write-Warning "Domain parsing failed for DomainEntry UID $($this.Uid)"
                }
            }

            # Initialize 'global-domain-assignments' field
            if ($obj.'global-domain-assignments' -and $obj.'global-domain-assignments' -is [object[]]) {
                $this.GlobalDomainAssignments = @()
                foreach ($gda in $obj.'global-domain-assignments') {
                    $gdaObj = [GlobalDomainAssignment]::new($gda)
                    if ($gdaObj) {
                        $this.GlobalDomainAssignments += $gdaObj
                    }
                }
            } else {
                $this.GlobalDomainAssignments = @()
            }

            $this.DomainType = [string]$obj.'domain-type'

            # Initialize 'servers' field
            if ($obj.servers -and $obj.servers -is [object[]]) {
                $this.Servers = @()
                foreach ($server in $obj.servers) {
                    $serverObj = [Server]::new($server)
                    if ($serverObj) {
                        $this.Servers += $serverObj
                    }
                }
            } else {
                $this.Servers = @()
            }

            $this.ManagementServerIP = $this.Servers | Where-Object {$_.type -eq 'management server'} | Select-Object -ExpandProperty IPv4Address

            $this.Comments = [string]$obj.comments
            $this.Color = [string]$obj.color
            $this.Icon = [string]$obj.icon

            if ($obj.tags -is [string[]]) {
                $this.Tags = $obj.tags
            } else {
                $this.Tags = @()
            }

            # Initialize 'meta-info' field
            if ($obj.'meta-info' -is [PSCustomObject]) {
                $this.MetaInfo = [MetaInfo]::new($obj.'meta-info')
            } elseif ($obj.'meta-info' -is [string]) {
                $parsedMetaInfo = ParseStringToPSCustomObject $obj.'meta-info'
                if ($parsedMetaInfo) {
                    $this.MetaInfo = [MetaInfo]::new($parsedMetaInfo)
                } else {
                    Write-Warning "MetaInfo parsing failed for DomainEntry UID $($this.Uid)"
                }
            }

            $this.ReadOnly = [bool]$obj.'read-only'
        } catch {
            Write-Error "Error initializing DomainEntry: $_"
        }
    }
}

Update-TypeData -TypeName 'DomainEntry' -Force -DefaultDisplayPropertySet @(
    'Uid'
    'Name'
    'ManagementServerIP'
)