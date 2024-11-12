# Common functions
function ndk_fpga_venv_prepare {
	if [ -z "$1" ]; then
		VENV_NAME="venv-cocotb"
	else
		VENV_NAME="$1"
	fi

	echo "Creating virtual environment '$VENV_NAME'"
	python -m venv $VENV_NAME
	source $VENV_NAME/bin/activate
}
