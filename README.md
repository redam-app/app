# Relational Database Management

This is simple application to manage relational databases.

## Installation

### Debian

**Latest:**
```bash
cd /tmp && curl -sLO https://raw.githubusercontent.com/redam-app/app/refs/heads/master/build/linux/redam.deb && sudo dpkg -i redam.deb
```

**Specific version:**
```bash
cd /tmp && curl -sLO https://raw.githubusercontent.com/redam-app/app/refs/tags/1.0.0/build/linux/redam.deb && sudo dpkg -i redam.deb
```

## Development

### Phar ###

**Install**
```bash
composer global require humbug/box
```
**Compile**
```bash
~/.config/composer/vendor/bin/box compile
```

### Binary ###

**Install**
```bash
composer global require phpacker/phpacker
```
**Compile**
```bash
~/.config/composer/vendor/bin/phpacker build all --src=./build/redam.phar --dest=./build/
```

### Debian package ###

**Compile**
```bash
cd build/linux && mkdir -p debian/usr/bin && cp linux-x64 debian/usr/bin/redam && dpkg-deb --build debian redam.deb && rm -rf debian/usr && cd ../..
```
