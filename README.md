# Relational Database Management

This is simple application to manage relational databases.

## Installation

### Debian

**Latest:**
```bash
cd /tmp && curl -sLO https://raw.githubusercontent.com/redam-app/app/refs/heads/master/build/linux/redam.deb && sudo dpkg -i redam.deb
```

or

```bash
curl -sLO https://raw.githubusercontent.com/redam-app/app/refs/heads/master/build/linux/linux-x64 && chmod +x linux-x64 && mv linux-x64 redam
```

**Specific version:**
```bash
cd /tmp && curl -sLO https://raw.githubusercontent.com/redam-app/app/refs/tags/1.0.0/build/linux/redam.deb && sudo dpkg -i redam.deb
```

or

```bash
curl -sLO https://raw.githubusercontent.com/redam-app/app/refs/tags/1.0.0/build/linux/linux-x64 && chmod +x linux-x64 && mv linux-x64 redam
```

## Development

### CS-Fixer ###
```bash
composer fix
```

### PHPStan ###
```bash
composer ps
```

### Phar ###

**Install**
```bash
composer global require humbug/box
```
**Compile**
```bash
composer phar
```

### Binary ###

**Install**
```bash
composer global require phpacker/phpacker
```
**Compile**
```bash
composer bin
```

### Debian package ###

**Compile**
```bash
composer deb
```
