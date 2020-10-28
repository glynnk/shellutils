install: install-commands install-plugins
uninstall: uninstall-commands

install-commands:
	commands/install

uninstall-commands:
	commands/uninstall

install-plugins:
	plugins/install
