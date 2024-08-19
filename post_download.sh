apt-get install pip -y
apt-get remove python3-sphinx -y
apt-get autoremove -y

PACKAGE_NAME=python3-sphinx-rtd-theme
mkdir -p $PACKAGE_NAME/DEBIAN
cat <<EOF >$PACKAGE_NAME/DEBIAN/control
Package: $PACKAGE_NAME
Version: 1.0
Architecture: all
Description: A dummy package
 This is a dummy package that does nothing.
EOF
dpkg-deb --build $PACKAGE_NAME
dpkg -i $PACKAGE_NAME.deb

PACKAGE_NAME=python3-sphinx
mkdir -p $PACKAGE_NAME/DEBIAN
cat <<EOF >$PACKAGE_NAME/DEBIAN/control
Package: $PACKAGE_NAME
Version: 1.0
Architecture: all
Description: A dummy package
 This is a dummy package that does nothing.
EOF
dpkg-deb --build $PACKAGE_NAME
dpkg -i $PACKAGE_NAME.deb

pip install sphinx==2.4 sphinx-rtd-theme Jinja2<3.1
