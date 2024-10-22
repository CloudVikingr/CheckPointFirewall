# ProtocolAttributeItem Class
class ProtocolAttributeItem {
    [string] $IsCHKPObject
    [string] $Resolved

    ProtocolAttributeItem() {}

    ProtocolAttributeItem([object] $obj) {
        try {
            if (-not $obj) { throw "ProtocolAttributeItem object is null." }
            $this.IsCHKPObject = [string]$obj.isCHKPObject
            $this.Resolved = [string]$obj.resolved
        } catch {
            Write-Error "Error initializing ProtocolAttributeItem: $_"
        }
    }
}

# OrigLogServerAttrItem Class
class OrigLogServerAttrItem {
    [string] $IsCHKPObject
    [string] $Uuid
    [string] $Resolved

    OrigLogServerAttrItem() {}

    OrigLogServerAttrItem([object] $obj) {
        try {
            if (-not $obj) { throw "OrigLogServerAttrItem object is null." }
            $this.IsCHKPObject = [string]$obj.isCHKPObject
            $this.Uuid = [string]$obj.uuid
            $this.Resolved = [string]$obj.resolved
        } catch {
            Write-Error "Error initializing OrigLogServerAttrItem: $_"
        }
    }
}

# SourceAttrItem Class
class SourceAttrItem {
    [string] $IsCHKPObject
    [string] $Resolved

    SourceAttrItem() {}

    SourceAttrItem([object] $obj) {
        try {
            if (-not $obj) { throw "SourceAttrItem object is null." }
            $this.IsCHKPObject = [string]$obj.isCHKPObject
            $this.Resolved = [string]$obj.resolved
        } catch {
            Write-Error "Error initializing SourceAttrItem: $_"
        }
    }
}

# MatchTableItem Class
class MatchTableItem {
    [string] $ParentRule
    [string] $RuleAction
    [string] $MatchId
    [string] $Rule
    [string] $RuleUid
    [string] $LayerName
    [string] $LayerUuid

    MatchTableItem() {}

    MatchTableItem([object] $obj) {
        try {
            if (-not $obj) { throw "MatchTableItem object is null." }
            $this.ParentRule = [string]$obj.parent_rule
            $this.RuleAction = [string]$obj.rule_action
            $this.MatchId = [string]$obj.match_id
            $this.Rule = [string]$obj.rule
            $this.RuleUid = [string]$obj.rule_uid
            $this.LayerName = [string]$obj.layer_name
            $this.LayerUuid = [string]$obj.layer_uuid
        } catch {
            Write-Error "Error initializing MatchTableItem: $_"
        }
    }
}

# LogEntry Class
class LogEntry {
    [string] $Destination
    [string] $Rule
    [string] $InterfaceDirection  # i_f_dir
    [ProtocolAttributeItem[]] $ProtocolAttribute
    [string] $RuleUid
    [string] $Type
    [string] $Interface            # __interface
    [OrigLogServerAttrItem[]] $OrigLogServerAttr
    [Nullable[DateTime]] $PolicyDate
    [string] $Action
    [string] $Id
    [string] $InterfaceName        # i_f_name
    [string] $LayerName
    [string] $SourcePort           # s_port
    [string] $ProductFamily
    [string] $Product
    [string] $SequenceNum          # sequencenum
    [string] $Source
    [SourceAttrItem[]] $SourceAttribute
    [string] $PolicyName
    [MatchTableItem[]] $MatchTable
    [bool] $IdGeneratedByIndexer
    [string] $DbTag
    [string] $OrigLogServer
    [string] $FService
    [string] $Origin               # orig
    [string] $Marker
    [string] $Service
    [string] $Domain
    [string] $Proto                # proto
    [string] $Protocol
    [string] $CalcDesc
    [string] $LogId
    [Nullable[DateTime]] $Time
    [string] $DropReason
    [bool] $First
    [string] $PolicyMgmt

    LogEntry() {}

    LogEntry([object] $obj) {
        try {
            if (-not $obj) { throw "LogEntry data is null." }

            $this.Destination = [string]$obj.dst
            $this.Rule = [string]$obj.rule
            $this.InterfaceDirection = [string]$obj.i_f_dir

            # ProtocolAttribute
            if ($obj.proto_attr -is [object[]]) {
                $this.ProtocolAttribute = $obj.proto_attr | ForEach-Object {
                    [ProtocolAttributeItem]::new($_)
                }
            } else {
                $this.ProtocolAttribute = @()
            }

            $this.RuleUid = [string]$obj.rule_uid
            $this.Type = [string]$obj.type
            $this.Interface = [string]$obj.__interface

            # OrigLogServerAttr
            if ($obj.orig_log_server_attr -is [object[]]) {
                $this.OrigLogServerAttr = $obj.orig_log_server_attr | ForEach-Object {
                    [OrigLogServerAttrItem]::new($_)
                }
            } else {
                $this.OrigLogServerAttr = @()
            }

            #$this.PolicyDate = $obj.policy_date
            # PolicyDate
            if ($obj.policy_date -and $obj.policy_date -ne '') {
                $this.PolicyDate = [DateTime]::Parse($obj.policy_date)
            } else {
                $this.PolicyDate = $null
            }

            $this.Action = [string]$obj.action
            $this.Id = [string]$obj.id
            $this.InterfaceName = [string]$obj.i_f_name
            $this.LayerName = [string]$obj.layer_name
            $this.SourcePort = [string]$obj.s_port
            $this.ProductFamily = [string]$obj.product_family
            $this.Product = [string]$obj.product
            $this.SequenceNum = [string]$obj.sequencenum
            $this.Source = [string]$obj.src

            # SrcAttr
            if ($obj.src_attr -is [object[]]) {
                $this.SourceAttribute = $obj.src_attr | ForEach-Object {
                    [SourceAttrItem]::new($_)
                }
            } else {
                $this.SourceAttribute = @()
            }

            $this.PolicyName = [string]$obj.policy_name

            # MatchTable
            if ($obj.match_table -is [object[]]) {
                $this.MatchTable = $obj.match_table | ForEach-Object {
                    [MatchTableItem]::new($_)
                }
            } else {
                $this.MatchTable = @()
            }

            $this.IdGeneratedByIndexer = [bool]$obj.id_generated_by_indexer
            $this.DbTag = [string]$obj.db_tag
            $this.OrigLogServer = [string]$obj.orig_log_server
            $this.FService = [string]$obj.fservice
            $this.Origin = [string]$obj.orig
            $this.Marker = [string]$obj.marker
            $this.Service = [string]$obj.service
            $this.Domain = [string]$obj.domain
            $this.Proto = [string]$obj.proto
            $this.Protocol = $obj.proto_attr.resolved
            $this.CalcDesc = [string]$obj.calc_desc
            $this.LogId = [string]$obj.logid

            # Time
            if ($obj.time -and $obj.time -ne '') {
                $this.Time = [DateTime]::Parse($obj.time)
            } else {
                $this.Time = $null
            }
            #$this.Time = $obj.time

            $this.DropReason = [string]$obj.drop_reason
            $this.First = [bool]$obj.first
            $this.PolicyMgmt = [string]$obj.policy_mgmt
        } catch {
            Write-Error "Error initializing LogEntry: $_"
        }
    }
}

Update-TypeData -TypeName 'LogEntry' -Force -DefaultDisplayPropertySet @(
    'Time'
    'Source'
    'Destination'
    'Service'
    'Protocol'
    'Action'
    'Origin'
    'PolicyName'
)