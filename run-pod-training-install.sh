#!/usr/bin/env bash
#################################################
# Assume is running on run-pod /workspace folder#
#################################################

# Read variables from run-pod-env.sh
# shellcheck source=/dev/null
if [[ -f run-pod-env.sh ]]
then
    source ./run-pod-env.sh
fi

cwd=$(pwd)

# Set defaults
# Install directory without trailing slash
if [[ -z "${install_dir}" ]]
then
    install_dir="/workspace"
fi

# Name of the subdirectory (defaults to stable-diffusion-webui)
if [[ -z "${sd_webui_dir}" ]]
then
    sd_webui_dir="stable-diffusion-webui"
fi

# Name of the subdirectory (defaults to models)
if [[ -z "${models_dir}" ]]
then
    models_dir="models"
fi

# Name of the subdirectory (defaults to models/Stable-diffusion)
if [[ -z "${sd_models_dir}" ]]
then
    sd_models_dir="Stable-diffusion"
fi

# Name of the subdirectory (defaults to extensions)
if [[ -z "${sd_extensions_dir}" ]]
then
    sd_extensions_dir="extensions"
fi

# Name of the subdirectory (defaults to sd_dreambooth_extension)
if [[ -z "${sd_dreambooth_extensions_dir}" ]]
then
    sd_dreambooth_extensions_dir="sd_dreambooth_extension"
fi

# Name of the subdirectory (defaults to sd-webui-additional-networks)
if [[ -z "${sd_additional_networks_dir}" ]]
then
    sd_additional_networks_dir="sd-webui-additional-networks"
fi

# Name of the subdirectory (defaults to a1111-sd-webui-locon)
if [[ -z "${sd_extended_lora_dir}" ]]
then
    sd_extended_lora_dir="a1111-sd-webui-locon"
fi

# Name of the subdirectory (defaults to requirements_versions-runpod-web-4.0.0.txt)
if [[ -z "${requirements_versions_file}" ]]
then
    requirements_versions_file="requirements_versions-runpod-web-4.0.0.txt"
fi

# Name of the subdirectory (defaults to requirements_versions-runpod-web-4.0.0.txt)
if [[ -z "${training_model_url}" ]]
then
    training_model_url="https://civitai.com/api/download/models/11745"
fi

# Name of the subdirectory (defaults to requirements_versions-runpod-web-4.0.0.txt)
if [[ -z "${training_models_file}" ]]
then
    training_models_file="chilloutmix_NiPrunedFp32Fix.safetensors"
fi

# git executable
if [[ -z "${GIT}" ]]
then
    export GIT="git"
fi

# Pretty print
delimiter="################################################################"

cd "${install_dir}"/ || { printf "\e[1m\e[31mERROR: Can't cd to %s/, aborting...\e[0m" "${install_dir}"; exit 1; }

if [[ -d "${sd_webui_dir}" ]]
then
    cd "${sd_webui_dir}"/ || { printf "\e[1m\e[31mERROR: Can't cd to %s/%s/, aborting...\e[0m" "${install_dir}" "${clone_dir}"; exit 1; }
else
    printf "\n%s\n" "${delimiter}"
    printf "stable-diffusion-webui not found. exit now"
    exit 1
fi

printf "\n%s\n" "${delimiter}"
printf "\e[1m\e[32mInstall extensions\n"
printf "\n%s\n" "${delimiter}"
cd "${sd_extensions_dir}"/ || { printf "\e[1m\e[31mERROR: Can't cd to %s/, aborting...\e[0m" "${sd_extensions_dir}"; exit 1; }

if [[ ! -d "${sd_dreambooth_extensions_dir}" ]]
then
    printf "\n%s\n" "${delimiter}"
    printf "Clone sd_dreambooth_extension"
    printf "\n%s\n" "${delimiter}"
    "${GIT}" clone https://github.com/d8ahazard/sd_dreambooth_extension "${sd_dreambooth_extensions_dir}"
    cd "${sd_dreambooth_extensions_dir}"/ || { printf "\e[1m\e[31mERROR: Can't cd to %s/%s/%s/%s, aborting...\e[0m" "${install_dir}" "${sd_webui_dir}" "${sd_extensions_dir}" "${sd_dreambooth_extensions_dir}"; exit 1; }
    pip install -r requirements.txt
    # Name of the subdirectory (defaults to sd_dreambooth_extension)
    if [[ -z "${TORCH_COMMAND}" ]]
    then
        pip install torch==1.13.1 torchvision --index-url https://download.pytorch.org/whl/cu117
    else
        exec "${TORCH_COMMAND}"
    fi  
    pip uninstall -y xformers
    pip install https://huggingface.co/MonsterMMORPG/SECourses/resolve/main/xformers-0.0.18.dev489-cp310-cp310-manylinux2014_x86_64.whl
fi

cd "${install_dir}/${sd_webui_dir}/${sd_extensions_dir}"/ || { printf "\e[1m\e[31mERROR: Can't cd to %s/, aborting...\e[0m" "${sd_extensions_dir}"; exit 1; }

if [[ ! -d "${sd_additional_networks_dir}" ]]
then
    printf "\n%s\n" "${delimiter}"
    printf "Clone sd-webui-additional-networks"
    printf "\n%s\n" "${delimiter}"
    "${GIT}" clone https://github.com/kohya-ss/sd-webui-additional-networks.git "${sd_additional_networks_dir}"
    cd "${sd_additional_networks_dir}"/ || { printf "\e[1m\e[31mERROR: Can't cd to %s/%s/%s/%s, aborting...\e[0m" "${install_dir}" "${sd_webui_dir}" "${sd_extensions_dir}" "${sd_additional_networks_dir}"; exit 1; }
fi

cd "${install_dir}/${sd_webui_dir}/${sd_extensions_dir}"/ || { printf "\e[1m\e[31mERROR: Can't cd to %s/, aborting...\e[0m" "${sd_extensions_dir}"; exit 1; }

if [[ ! -d "${sd_extended_lora_dir}" ]]
then
    printf "\n%s\n" "${delimiter}"
    printf "Clone a1111-sd-webui-locon"
    printf "\n%s\n" "${delimiter}"
    "${GIT}" clone https://github.com/KohakuBlueleaf/a1111-sd-webui-locon.git "${sd_extended_lora_dir}"
    cd "${sd_extended_lora_dir}"/ || { printf "\e[1m\e[31mERROR: Can't cd to %s/%s/%s/%s, aborting...\e[0m" "${install_dir}" "${sd_webui_dir}" "${sd_extensions_dir}" "${sd_extended_lora_dir}"; exit 1; }
fi

cd "${install_dir}/${sd_webui_dir}/${models_dir}/${sd_models_dir}"/ || { printf "\e[1m\e[31mERROR: Can't cd to %s/, aborting...\e[0m" "${sd_models_dir}"; exit 1; }
if [[ ! -f "${training_models_file}" ]]
then
    printf "\n%s\n" "${delimiter}"
    printf "\e[1m\e[32mDownloading Training Models\n"
    printf "\n%s\n" "${delimiter}"
    wget "-O" "${training_models_file}" "${training_model_url}"
fi

printf "\n%s\n" "${delimiter}"
printf "\e[1m\e[32mreplacing requirements_versions.txt \n"
cp "${cwd}/requirements_versions-runpod-web-4.0.0.txt" "${install_dir}/${sd_webui_dir}/requirements_versions.txt"
printf "\n%s\n" "${delimiter}"

printf "\n%s\n" "${delimiter}"
printf "\e[1m\e[32mInstallation completed..please restart runpod\n"
printf "\n%s\n" "${delimiter}"