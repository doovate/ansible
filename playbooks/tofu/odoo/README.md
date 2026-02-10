# Terraform Proxmox VM Deployment

Sistema automatizado para el despliegue de máquinas virtuales en Proxmox utilizando Terraform, con un script de gestión interactivo en Python.

## 📋 Requisitos Previos

- **Terraform** >= 1.8
- **Python** 3.x
- **Proxmox VE** con acceso API
- **Template Ubuntu 24.04** configurado en Proxmox
- Token de API de Proxmox configurado

## 🚀 Características

- ✨ Interfaz interactiva para gestionar la configuración de VMs
- 🔧 Configuración simplificada de recursos (CPU, RAM, disco, red)
- 📦 Despliegue automatizado con Terraform
- 🧹 Limpieza automática de archivos residuales
- 🔐 Gestión segura de credenciales mediante archivos `.tfvars`

## 📁 Estructura del Proyecto

```
.
├── deploy.py                    # Script principal de gestión
├── main.tf                      # Configuración de recursos Proxmox
├── provider.tf                  # Configuración del provider Terraform
├── variables.tf                 # Definición de variables
├── output.tf                    # Outputs de Terraform
├── credentials.auto.tfvars      # Credenciales y configuración (NO versionar)
└── README.md                    # Este archivo
```

## ⚙️ Configuración Inicial

### 1. Clonar el Repositorio

```bash
git clone <url-del-repositorio>
cd <directorio-del-proyecto>
```

### 2. Crear Archivo de Credenciales

Crea el archivo `credentials.auto.tfvars` con la siguiente estructura:

```hcl
# Credenciales Proxmox
proxmox_api_url          = "https://tu-proxmox:8006/api2/json"
proxmox_api_token_id     = "usuario@pam!token-id"
proxmox_api_token_secret = "tu-token-secret"
proxmox_node             = "nombre-nodo"

# Configuración de la VM
hostname    = "mi-vm"
description = "Descripción de la VM"
template    = "template-ubuntu-24.04"

# Recursos
cpu_cores   = 4
cpu_vcpu    = 4
ram         = 4096     # En MB
balloon     = 4096     # En MB
disk_size   = 20       # En GB

# Red
ip          = "192.168.124.25"
gateway     = "192.168.124.1"
dns_server  = "1.1.1.1"

# Usuario
tsg_user     = "tsg"
tsg_password = "tu-password"
tsg_key      = "ssh-rsa AAAA... tu-clave-publica"

# Otros
datastore = "local"
vm_tags   = "test"
```

### 3. Configurar `.gitignore`

Asegúrate de que tu `.gitignore` incluya:

```gitignore
# Terraform
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl

# Credenciales
credentials.auto.tfvars
*.auto.tfvars

# Python
__pycache__/
*.pyc
```

## 🎯 Uso del Script de Gestión

### Ejecutar el Script

```bash
python3 deploy.py
```

### Menú Principal

```
1. 📝 Actualizar configuración
2. 👁️  Ver configuración actual
3. 🚀 Desplegar VM
4. 🧹 Limpiar archivos residuales
5. 🚪 Salir
```

#### Opción 1: Actualizar Configuración
Permite modificar los parámetros de la VM de forma interactiva:
- Hostname
- Descripción
- CPU (cores y vCPU)
- RAM (en GB, se convierte automáticamente a MB)
- Balloon Memory (en GB)
- Tamaño de disco
- Dirección IP
- Gateway

#### Opción 2: Ver Configuración Actual
Muestra la configuración actual de la VM en formato tabla.

#### Opción 3: Desplegar VM
Ejecuta el proceso completo de despliegue:
1. `terraform init` - Inicializa el proyecto
2. `terraform plan` - Muestra los cambios planificados
3. `terraform apply` - Aplica los cambios y crea la VM

#### Opción 4: Limpiar Archivos Residuales
Elimina archivos temporales de Terraform:
- `terraform.tfstate`
- `terraform.tfstate.backup`
- `.terraform.lock.hcl`
- Directorio `.terraform/`

## 🔧 Uso Manual de Terraform

Si prefieres usar Terraform directamente:

```bash
# Inicializar
terraform init

# Ver plan de despliegue
terraform plan

# Aplicar cambios
terraform apply

# Destruir recursos
terraform destroy
```

## 📝 Configuración de la VM

### Recursos de CPU
- **cpu_cores**: Número de cores asignados
- **cpu_sockets**: Número de sockets (default: 1)
- **cpu_type**: Tipo de CPU (default: kvm64)

### Memoria
- **ram**: Memoria máxima en MB
- **balloon**: Memoria mínima garantizada en MB

### Almacenamiento
- **disk_size**: Tamaño del disco en GB
- **datastore**: Almacén de datos en Proxmox

### Red
- **ip**: Dirección IP con notación CIDR (/23)
- **gateway**: Puerta de enlace predeterminada
- **dns_server**: Servidor DNS

## 🔐 Seguridad

⚠️ **IMPORTANTE**: 
- **NUNCA** subas el archivo `credentials.auto.tfvars` a Git
- Usa tokens de API específicos con permisos limitados
- Considera usar herramientas como HashiCorp Vault para gestión de secretos en producción
- Las contraseñas SSH y tokens son marcadas como `sensitive` en Terraform

## 🐛 Troubleshooting

### Error: "terraform: command not found"
```bash
# Instalar Terraform
wget https://releases.hashicorp.com/terraform/1.12.2/terraform_1.12.2_linux_amd64.zip
unzip terraform_1.12.2_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

### Error: "Failed to instantiate provider"
```bash
# Limpiar y reinicializar
rm -rf .terraform .terraform.lock.hcl
terraform init
```

### Error: "Permission denied" al ejecutar deploy.py
```bash
chmod +x deploy.py
```

## 📚 Recursos Adicionales

- [Documentación Terraform Proxmox Provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
- [Documentación Proxmox VE](https://pve.proxmox.com/wiki/Main_Page)
- [Terraform Documentation](https://www.terraform.io/docs)

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:
1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 👥 Autor

TSG - Terraform Proxmox VM Manager

## 📞 Soporte

Para reportar problemas o solicitar nuevas funcionalidades, por favor abre un issue en el repositorio.