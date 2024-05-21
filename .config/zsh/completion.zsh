if [ $(command -v "kubectl") ]
    then source <(kubectl completion zsh)
fi

if [ $(command -v "helm") ]
    then source <(helm completion zsh)
fi

if [ $(command -v "podman") ]
    then source <(podman completion zsh)
elif [ $(command -v "docker") ]
    then source <(docker completion zsh)
fi

_dotnet_zsh_complete()
{
    local completions=("$(dotnet complete "$words")")

    # If the completion list is empty, just continue with filename selection
    if [ -z "$completions" ]
    then
        _arguments '*::arguments: _normal'
        return
    fi

    # This is not a variable assignment, don't remove spaces!
    _values = "${(ps:\n:)completions}"
}

compdef _dotnet_zsh_complete dotnet
