FROM pytorch/pytorch:1.8.0-cuda11.1-cudnn8-runtime
MAINTAINER author "missingstuffedbun@hotmail.com"

WORKDIR /workspace

# Base
RUN apt-get update --fix-missing -o Acquire::http::No-Cache=True
RUN apt-get -y -q install wget vim cmake git 

# SHELL ["/bin/bash", "--login", "-c"]

# Anaconda Install
# RUN wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/Anaconda3-5.2.0-Linux-x86_64.sh -O ~/Anaconda3-5.2.0-Linux-x86_64.sh
COPY Anaconda3-2020.02-Linux-x86_64.sh ./Anaconda3-2020.02-Linux-x86_64.sh
RUN bash ./Anaconda*.sh -b -p ~/anaconda3 \
	&& rm ./Anaconda*.sh 
RUN \
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/main/ && \
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/free/ && \
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/conda-forge/ && \
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/msys2/ && \
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/bioconda/ && \
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/menpo/ && \
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/pytorch/
RUN \
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/msys2/ && \
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/ && \
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
RUN conda config --set show_channel_urls yes
RUN conda config --set offline true

ENV PATH ~/anaconda3/bin:$PATH
RUN echo "conda deactivate" >> ~/.bashrc
# RUN echo "/opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc
# RUN conda init bash

# ViT
RUN conda create -n vit -y
SHELL ["conda", "run", "-n", "vit", "/bin/bash", "-c"]
# RUN git clone https://github.com/google-research/vision_transformer.git
COPY vision_transformer ./vision_transformer
RUN pip install -i https://mirrors.huaweicloud.com/repository/pypi/simple pip -U
RUN pip config set global.index-url https://mirrors.huaweicloud.com/repository/pypi/simple
RUN pip install -r ./vision_transformer/vit_jax/requirements.txt 
RUN pip install prompt_toolkit==2.0.9
RUN python -m ipykernel install --user --name vit --display-name "ViT"

# T2T
RUN conda create -n t2t -y 
SHELL ["conda", "run", "-n", "t2t", "/bin/bash", "-c"]
RUN pip install -i https://mirrors.huaweicloud.com/repository/pypi/simple pip -U
RUN pip config set global.index-url https://mirrors.huaweicloud.com/repository/pypi/simple
RUN pip install tensor2tensor
RUN pip install prompt_toolkit==2.0.9
RUN python -m ipykernel install --user --name t2t --display-name "T2T"


# Trax - Pretrained T2T
RUN conda create -n trax -y
SHELL ["conda", "run", "-n", "trax", "/bin/bash", "-c"]
RUN conda env list
RUN pip install -i https://mirrors.huaweicloud.com/repository/pypi/simple pip -U
RUN pip config set global.index-url https://mirrors.huaweicloud.com/repository/pypi/simple
RUN pip install trax
RUN pip install prompt_toolkit==2.0.9
RUN python -m ipykernel install --user --name trax --display-name "Trax"

# DETR
RUN conda create -n detr -y
SHELL ["conda", "run", "-n", "detr", "/bin/bash", "-c"]
RUN conda env list
# RUN conda install pytorch torchvision 
RUN pip install -i https://mirrors.huaweicloud.com/repository/pypi/simple pip -U
RUN pip config set global.index-url https://mirrors.huaweicloud.com/repository/pypi/simple
RUN pip install torch torchvision
RUN pip install prompt_toolkit==2.0.9
RUN python -m ipykernel install --user --name detr --display-name "DETR"


# Jupyter
SHELL ["/bin/bash", "-c"]
RUN jupyter notebook --generate-config
RUN python -c "from notebook.auth import passwd; print(\"c.NotebookApp.password = u'\" +  passwd('3582521') + \"'\")" >> ~/.jupyter/jupyter_notebook_config.py
RUN echo c.NotebookApp.port = 9004  >> ~/.jupyter/jupyter_notebook_config.py
RUN echo c.NotebookApp.terminado_settings = {\"shell_command\": [\"/bin/bash\"]}  >> ~/.jupyter/jupyter_notebook_config.py


CMD jupyter notebook --ip='0.0.0.0' --no-browser --port=9004 --allow-root
#CMD ["jupyter", "notebook", "--ip='0.0.0.0'", "--no-browser", "--port=9004", "--allow-root"]
