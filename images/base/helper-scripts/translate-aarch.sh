#!/bin/bash
# https://en.wikipedia.org/wiki/Uname#Examples

transform_aarch() {
    definition=$1
    return_value="not-defined"
    case "$(uname -i)" in
        # AMD64 or x86-64 or x64
        amd64|x86_64|x64)
            case $definition in
                x-long) return_value="x86-64";;
                x-short) return_value="x64";;
                a-long) return_value="amd64";;
                a-short) return_value="amd64";;
                *) return_value="not-defined";;
            esac
            ;;
        x86)
            case $definition in
                x-long) return_value="x86";;
                x-short) return_value="x86";;
                a-long) return_value="amd32";;
                a-short) return_value="amd";;
                *) return_value="not-defined";;
            esac
            ;;
    esac
    echo -n "$return_value"
}

echo $(transform_aarch $1)