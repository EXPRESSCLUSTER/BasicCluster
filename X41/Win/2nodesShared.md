# How to setup basic 2 nodes shared disk cluster

## Overview
This article shows quick setup of a basic 2 nodes shred disk cluster, which has floating IP address feature (fip) and shared disk feature.
For shared disk cluster configuration, Primary Server and Secondary Servers should have Shared Disk.

## Reference
Please also refer EXPRESSCLUSTER Manuals for more details:
- [EXPRESSCLUSTER X 4.1 for Windows System Requirements](https://www.nec.com/en/global/prod/expresscluster/en/overview/sysrep_wx.html?)
- [EXPRESSCLUSTER X 4.1 for Windows Getting Started Guide](https://www.nec.com/en/global/prod/expresscluster/en/support/Windows/W41_SG_EN_04.pdf)
- [EXPRESSCLUSTER X 4.1 Installation Guide for Windows](https://www.nec.com/en/global/prod/expresscluster/en/support/manuals.html)

## Cluster System Configuration
```bat
<Public LAN>
 |
 | <Private LAN>
 |  |
 |  |  +--------------------------------+           +-------------+
 +-----| Primary Server                 |           |             |
 |  |  |  OS: Windows Server            +===========+             |
 |  +--|  EXPRESSCLUSTER X 4.1/4.2      |           |             |
 |  |  +--------------------------------+           |   Shared    |
 |  |                                               |   Disk      |
 |  |  +--------------------------------+           |             |
 +-----| Secondary Server               |           |             |
 |  |  |  OS: Windows Server            +===========+             |
 |  +--|  EXPRESSCLUSTER X 4.1/4.2      |           |             |
 |  |  +--------------------------------+           +-------------
 |  |
 |  |
 |  |  +--------------------------------+
 +-----| Client machine                 |
 |  |  +--------------------------------+
 |  |
 | [Switch]
 |  :
 |
[Gateway]
 :
```
### Requirements
- Primary Server, Secondary Server and Client machine sould be reachable with IP address.
- Ports which EXPRESSCLUSTER requires should be opend.
	- You can open ports by executing OpenPort.bat([X4.1](https://github.com/EXPRESSCLUSTER/Tools/blob/master/OpenPorts.bat)/[X4.2](https://github.com/EXPRESSCLUSTER/Tools/blob/master/OpenPorts_X42.bat)) on all servers
- 2 partitions are required on Shared Disk:
	- Disk NP Partition: 20MB, RAW (do not format this partition)
	- Switch Partition: Depends on shared data size (NTFS)

### Sample configuration
- Primary/Secondary Servers
	- OS: Windows Server 2016/2019
	- EXPRESSCLUSTER X: 4.1 or 4.2
	- CPU: 2
	- Memory: 8MB
	- Disk (Each server's local disk)
		- C:
			- Size: Depending on system requirements
- Shared Disk
	- Partitions
		- Z:
			- Size: 20MB
			- File system: RAW (do NOT format)
		- E:
			- Size: Depending on data size
			- File system: NTFS
		- **Attention**
			- Dynamic Disk is NOT supported, only Basic disk is supported for cluster shared disk.
			- Sftware RAID or Volume set is NOT supported for cluster shared disk.
			- GPT is better than MBR to keep drive letter.
- Required Licenses
	- Core license:
		- In the case of physical servers: 6 CPUs
		- In the case of virtual machines: 2 nodes
	- (Optional) Other Option licenses: 2 nodes

- IP address  

| |Public IP |Private IP |
|-----------------|-----------------|-----------------|
|Primary Server |10.1.1.11 |192.168.1.11 |
|Secondary Server |10.1.1.12 |192.168.1.12 |
|fip |10.1.1.21 |- |
|Client machine |10.1.1.51 |- |
|Gateway |10.1.1.1 |- |

## System setup
### Preparation
1. Confirm that there are no data on Shared Disk
	- If there are any data, backup it
1. Stop both Primary and Secondary Servers
1. Connect Shared Disk to Primary Server

### Install EXPRESSCLUSTER X
#### On Primary Server
1. Connect Shared Disk to Primary Server
1. Start only Primary Server
	- **Attention**
		-To avoid multi access form Primary and Secondary Server to Shared Disk, start ONLY Primary Server.  
			If connectiong Sahred Disk to both Primary and Secodnary Servers and starting them before setting access filtering by ECX, data on Shared Disk may corrupt.
1. Start Windows Computer Management window and make Shared Disk online
	- If you initialize the disk at this time, GPT type is recommended.
1. Create 2 partitions on Shared Disk
	- Z:
		- Size: 20MB
		- File system: RAW (do NOT format)
	- E:
		- Size: Depending on data size
		- File system: NTFS
1. Open ports for EXPRESSCLUSTER
	- You can open ports by executing OpenPort.bat([X4.1](https://github.com/EXPRESSCLUSTER/Tools/blob/master/OpenPorts.bat)/[X4.2](https://github.com/EXPRESSCLUSTER/Tools/blob/master/OpenPorts_X42.bat)) on both servers
1. Start ECX Installer
	- Choose Destination Location: Default
	- Ready to install Program: Install
	- Port Number: Default
	- Filter Settings of Shared Disk
		- Right click HBA port (Green icon) under which Shared Disk is shown and select "Filtering" to set access filtering
		- Confirm that the partitions on Shared Disk are checked
			- **Attention**
				- If C: partition is checked, OS may not rebooted. In such a case, right click C: and select "Cancel Filtering".
	- License Manager: Register licenses
		- Core license
		- (Optional) Other Option licenses
1. Reboot
1. Confirm that the partitions, Z: and E: are not accessible
	- **Attention**
		- If you can access the partitions, access filter setting is not set properly. Please follow steps below:
			- Start Windows Computer Management window and make Shared Disk OFFLINE

#### On Secondary Server
1. Connect Shared Disk to Secondary Server
1. Start Secondary Server
1. Start Windows Computer Management window and make Shared Disk online
1. Confirm that you can see the partitions which you created on Primary Server
	- Z:
		- Size: 20MB
		- File system: RAW (do NOT format)
	- E:
		- Size: Depending on data size
		- File system: NTFS
	- **Note**
		- If driver letter was different from Primary Server, please change them as same as Primary Server 
1. Open ports for EXPRESSCLUSTER
	- You can open ports by executing OpenPort.bat([X4.1](https://github.com/EXPRESSCLUSTER/Tools/blob/master/OpenPorts.bat)/[X4.2](https://github.com/EXPRESSCLUSTER/Tools/blob/master/OpenPorts_X42.bat)) on both servers
1. Start ECX Installer
	- Choose Destination Location: Default
	- Ready to install Program: Install
	- Port Number: Default
	- Filter Settings of Shared Disk
		- Right click HBA port (Green icon) under which Shared Disk is shown and select "Filtering" to set access filtering
		- Confirm that the partitions on Shared Disk are checked
			- **Note** If C: partition is checked, OS may not rebooted. In such a case, right click C: and select "Cancel Filtering".
	- License Manager: Register licenses
		- Core license
		- (Optional) Other Option licenses
1. Reboot
1. Confirm that the partitions, Z: and E: are not accessible
	- **Attention**
		- If you can access the partitions, access filter setting is not set properly. Please follow steps below:
			- Start Windows Computer Management window and make Shared Disk OFFLINE

#### A) In the case that both servers HBA filter settins are set properly
If HBA filtering is not set properly on one server or both servers, skip this A) steps and goto B).

##### On Primary Server
1. Start Cluster WebUI
	- Desktop shortcut icon or http://localhost:29003
	- Move to Config Mode
	- Cluster generation wizard
1. Create a new cluster configuration with cluster generation wizard
	- Cluster
		- Cluster name: As you like
		- Language: As you like
	- Basic Settings
		- Click Add and set Secondary Server IP address, 10.1.1.12 or 192.168.1.12
	- Interconnects
		- Set as follows
    
		|Priority |Type |MDC |Primary Server |Secondary Server |
		|---------|------------|-----|-----------------|-----------------|
		|1 |Kernel Mode |Do not use |10.1.1.11 |10.1.1.12 |
		|1 |Kernel Mode |Do not use |192.168.1.11 |192.168.1.12 |
	- NP Resolution
		- Add
		- Set as follows
    
		|Type |Target |Primary Server |Secondary Server |
		|-----|---------|-----------------|-----------------|
		|Ping |10.1.1.1 |Use |Use |
		|DISK |- |Z: |Z: |- |
	- Group
		- Add
		- Basic Settings
			- Type: failover
			- Name: As you like
		- Group Resources
			- Add
				-Info
					- Type: Floating IP resource
					- Name: As you like
				- Dependency
					- Default
				- Recovery Operation
					- Default
				- Details
					- IP Address: 10.1.1.21
			- Add
				-Info
					- Type: Disk resource
					- Name: As you like
				- Dependency
					- Default
				- Recovery Operation
					- Default
				- Details
					- Drive Letter: E
					- Select Primary Server
						- Click Add
						- Select E: and click OK
					- Secondary Server
						- Click Add
						- Select E: and click OK
					- **Note**
						- After adding both Primary Server and Secondary Server, confirm that both servers shows the same GUID.
	- Monitor
		- Default
	- Finish
1. Apply the Configuration

#### B) In the case that both servers HBA filter settins are set properly
If HBA filtering is set properly on one both servers and you have follows A) steps, skip this B) steps.

##### On Primary Server
1. Start Cluster WebUI
	- Desktop shortcut icon or http://localhost:29003
	- Move to Config Mode
	- Cluster generation wizard
1. Create a new cluster configuration with cluster generation wizard
	- Cluster
		- Cluster name: As you like
		- Language: As you like
	- Basic Settings
		- Click Add and set Secondary Server IP address, 10.1.1.12 or 192.168.1.12
		- Click Add and set DR Server IP address, 10.1.1.13 or 192.168.1.13
	- Interconnects
		- Set as follows
    
		|Priority |Type |MDC |Primary Server |Secondary Server |
		|---------|------------|-----|-----------------|-----------------|
		|1 |Kernel Mode |Do not use |10.1.1.11 |10.1.1.12 |
		|1 |Kernel Mode |Do not use |192.168.1.11 |192.168.1.12 |
	- Group
		- Next
			- **Attention***
				- Please do not add resources to failovergroup at this time
	- Monitor
		- Default
	- Finish
1. Apply the Configuration
- **Atention**
	- After applying the Configuration, please do NOT reboot servers.

##### On one server which HBA filtering is not set properly (Failed Server)
1. Start Cluster WebUI
	- Desktop shortcut icon or http://localhost:29003
	- Move to Config Mode
1. Set HBA filtering for Failed Server
	- Click Propeties of Failed Server
	- Goto HBA tab and click Connect
	- Check HBA port which is connected to Shared Disk
		- **Note**
			- By select HBA port and click Add, you can confirm which partitions are connected HBA port.
			- After confirming, click Cancel, not OK.
	- Click OK
1. Apply the Configuration
1. Reboot
1. Confirm that the partitions, Z: and E: are not accessible
	- **Attention**
		- If you can access the partitions, access filter setting is not set properly. Please ask support team.
1. If you have failed HBA filtering on both servers, do the same on other server.
	- **Attention**
		- Please do one by one, not in parallel.

##### On Primary Server
1. Start Cluster WebUI
	- Desktop shortcut icon or http://localhost:29003
	- Move to Config Mode
1. Add NP Resolution
	- Click Cluster Properties
	- Goto NP Resolution tab
	- Set as follows
    
		|Type |Target |Primary Server |Secondary Server |
		|-----|---------|-----------------|-----------------|
		|Ping |10.1.1.1 |Use |Use |
		|DISK |- |Z: |Z: |- |
1. Add group resources
	- Resource 1
		-Info
			- Type: Floating IP resource
			- Name: As you like
		- Dependency
			- Default
		- Recovery Operation
			- Default
		- Details
			- IP Address: 10.1.1.21
	- Resource 2
		-Info
			- Type: Disk resource
			- Name: As you like
		- Dependency
			- Default
		- Recovery Operation
			- Default
		- Details
			- Drive Letter: E
			- Select Primary Server
				- Click Add
				- Select E: and click OK
			- Secondary Server
				- Click Add
				- Select E: and click OK
			- **Note**
				- After adding both Primary Server and Secondary Server, confirm that both servers shows the same GUID.
1. Apply the Configuration.

### Check cluster
#### On Primary Server
1. Move to Cluster WebUI Operation Mode
1. Confirm that failover group is Online on Primary Server and there are no Errors/Cautions
1. Execute "ipconfig" command and check fip address 10.1.1.21 exists to confirm that fip feature works.
1. Make test file on E:
	- e.g. E:\test.txt
1. On Cluster WebUI, move failover group from Primary Server to Secondary Server

#### On Secondart Server
1. Start Cluster WebUI Operation Mode
1. Confirm that failover group is Online on Secondary Server and there are no Errors/Cautions
1. Execute "ipconfig" command and check fip address 10.1.1.21 exists to confirm that fip feature works.
1. Confirm that the test file "E:\test.txt" exists
1. On Cluster WebUI, move failover group back from Secondary Server to Primary Server

## Tips
If you are creating shared disk on vSphere vmfs datastore, here is a quick guide:  
[How to create a shared disk cluster on vSphere ESXi](https://github.com/EXPRESSCLUSTER/Tips/blob/master/SharedDiskOnvSphere.md)

