# opennebula-build-image
Build images for Opennebul (KVM) with a make file and inject packages or scripts. This image can later be use in terraform or by uploading. Examples at the end.

## Requirements
- Docker 
## more scripts
create a new script in `scripts/[distro]` and also append it to `scripts/[distro]/entry.sh` to execute it on build. Network should be available on build (virt-customize: `--network`) and files from the script folder can be copied. 

## Examples 

### Terraform
#### Image
```tf
resource "opennebula_image" "custom-ubuntu" {
	name         = "custom-ubuntu"
	datastore_id = 1
	type 		= "OS"
	persistent	= false
	path 		= "[http://pach/to/your/builded.img]" // if on opennebula-host, file-path can be given
	dev_prefix 	= "vd"
	format 		= "qcow2"
}
```
#### VM-Template
```hcl
resource "opennebula_template" "myubuntu" {
    name        = "myubuntu"
    permissions = "660"

	cpu         = 1
  	vcpu        = 2
  	memory      = 1024

    disk {
		image_id = opennebula_image.custom-ubuntu.id
        size     = 5120
    }

	context = {
		NETWORK			= "YES"
    	HOSTNAME		= "$NAME"
		REPORT_READY	= "YES"
		SSH_PUBLIC_KEY = "$USER[SSH_PUBLIC_KEY]"
	}

	graphics {
		type = "vnc"
		listen = "0.0.0.0"
	}

    os {
        arch = "x86_64"
		boot = ""
    }
}
```
#### VM
```hcl
resource "opennebula_virtual_machine" "myubuntu-instance" {
  name        = "myubuntu-instance"
  template_id = opennebula_template.myubuntu.id

  os {
    arch = "x86_64"
    boot = "disk0"
  }

  disk {
    image_id = opennebula_image.consul-ubuntu.id
    target   = "vda"
    driver   = "qcow2"
    size     = 10240
  }
}
```
### Templates
#### Image
#### VM-Template
#### VM

## Sources
Inspired by: https://opennebula.io/creating-customized-images/