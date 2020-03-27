##### Set the following parameters #####
$originalConfPath = "C:tmp"

$primary_serverName = "server1"
$secondary_serverName = "server2"

$primary_PublicIp = "10.1.1.11"
$primary_PrivateIp = "192.168.1.11"

$secondary_PublicIp = "10.1.1.12"
$secondary_PrivateIp = "192.168.1.12"

$gatewayIp = "10.1.1.1"

$fip = "10.1.1.21"

$clusterPartition = "X"
$dataPartition = "E"
#######################################


######## Don't change from here #######
$default_pri = "server1"
$default_sec = "server2"

$confPath = $originalConfPath + "\clp.conf"

# Load clp.conf
$confXml = [xml](Get-Content $confPath)

# Replce Primary Server IP address
$node = $confXml.root.server | Where{$_.name -eq $default_pri}

$ip = $node.device | Where{$_.id -eq 0}
$ip.info = $primary_PublicIp
$ip = $node.device | Where{$_.id -eq 401}
$ip.info = $primary_PublicIp
$ip.mdc.info = $primary_PublicIp

$ip = $node.device | Where{$_.id -eq 1}
$ip.info = $primary_PrivateIp
$ip = $node.device | Where{$_.id -eq 400}
$ip.info = $primary_PrivateIp
$ip.mdc.info = $primary_PrivateIp

# Replce Secondary Server IP address
$node = $confXml.root.server | Where{$_.name -eq $default_sec}
$ip = $node.device | Where{$_.id -eq 0}
$ip.info = $secondary_PublicIp
$ip = $node.device | Where{$_.id -eq 401}
$ip.info = $secondary_PublicIp
$ip.mdc.info = $secondary_PublicIp

$ip = $node.device | Where{$_.id -eq 1}
$ip.info = $secondary_PrivateIp
$ip = $node.device | Where{$_.id -eq 400}
$ip.info = $secondary_PrivateIp
$ip.mdc.info = $secondary_PrivateIp

# Replace server name
$node = $confXml.root.server
for($i=0; $i -le $node.Length; $i++){
    if ($node[$i].name -eq $default_pri){
        $node[$i].name = $primary_serverName
    }elseif($node[$i].name -eq $default_sec){
        $node[$i].name = $secondary_serverName
    }
}

# Replace ping NP IP address
$confXml.root.networkpartition.pingnp.grp.list.ip = $gatewayIp = "10.1.1.1"

# Replace fip address
$confXml.root.resource.fip.parameters.ip = $fip

# Replace drive letters for md
$node = $confXml.root.resource.md
$node.parameters.volumemountpoint = $dataPartition
$node.parameters.cpvolumemountpoint = $clusterPartition

for($i=0; $i -le $node.server.Length; $i++){
    if($node.server[$i].name -eq $default_pri){
        $node.server[$i].name = $primary_serverName
    }elseif($node.server[$i].name -eq $default_sec){
        $node.server[$i].name = $secondary_serverName
    }
}

# Save config
$confXml.Save($confPath)

# Complress clp.conf.zip
$updateConfPath = $originalConfPath + "\clpconf_2nodeMirror_update.zip"
Compress-Archive -Path $confPath -DestinationPath $updateConfPath

Read-Host "Cluster configuration is changed and zipped."
