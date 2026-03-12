# 1. Check and install Python (system needs it for conda)
if ! command -v python3 &> /dev/null; then
    echo "Python3 not found. Installing via apt..."
    sudo apt update
    sudo apt install -y python3 python3-pip
    echo "Python3 installed: $(python3 --version)"
else
    echo "Python3 already available: $(python3 --version)"
fi


# 2. Check and install Git
if ! command -v git &> /dev/null; then
    echo "Git not found. Installing via apt..."
    sudo apt install -y git
    echo "Git installed: $(git --version)"
else
    echo "Git already available: $(git --version)"
fi


# 3. Check and install Miniconda
MINICONDA_PATH="$HOME/.miniconda3"
if ! command -v conda &> /dev/null; then
    echo "Miniconda not found. Installing..."
    MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
    wget "$MINICONDA_URL" -O miniconda.sh
    bash miniconda.sh -b -p "$MINICONDA_PATH"
    rm miniconda.sh
    "$MINICONDA_PATH/bin/conda" init bash
    . ~/.bashrc
    echo "Miniconda installed at $MINICONDA_PATH"
else
    echo "Miniconda already available."
fi


# Reload conda
eval "$(conda shell.bash hook 2> /dev/null)"


# 4. Create and activate environment (assumes environment.yml in current dir)
conda env create -f environment.yml
conda activate MobMetrics
echo "MobMetrics environment activated."


# 5. Django migrations (assumes MobMetrics/ in current dir)
echo "Running migrations..."
python MobMetrics/manage.py makemigrations metrics
python MobMetrics/manage.py migrate


# 6. Check and install JDK in the environment
if ! command -v java &> /dev/null; then
    echo "JDK not found. Installing OpenJDK in the environment..."
    conda install -y -c conda-forge openjdk
    echo "JDK installed: $(java -version 2>&1 | head -n1)"
else
    echo "JDK already available: $(java -version 2>&1 | head -n1)"
fi


# 7. Download and install BonnMotion (requires JDK to compile Java)
echo "Downloading BonnMotion v3.0.1..."
BONNMOTION_URL="https://bonnmotion.sys.cs.uos.de/src/bonnmotion-3.0.1.zip"
BONNMOTION_DIR="bonnmotion-3.0.1"
wget "$BONNMOTION_URL" -O bonnmotion.zip
unzip -o bonnmotion.zip
rm bonnmotion.zip


if [ -d "$BONNMOTION_DIR" ]; then
    cd "$BONNMOTION_DIR"
    ./install
    echo "BonnMotion installed in ./$BONNMOTION_DIR."
    cd ..
else
    echo "Error: Directory $BONNMOTION_DIR not found."
    exit 1
fi


# 8. Add permanent alias in .bashrc to run server
ALIAS_CMD='alias mobmetrics="cd ~/MobMetrics && conda activate MobMetrics && python ~/MobMetrics/MobMetrics/manage.py runserver"'
if ! grep -q "$ALIAS_CMD" ~/.bashrc; then
    echo "$ALIAS_CMD" >> ~/.bashrc
    echo "Alias 'mobmetrics' added to .bashrc."
else
    echo "Alias 'mobmetrics' already exists in .bashrc."
fi

source ~/.bashrc

echo "Installation complete! Use 'mobmetrics' to start the server."
