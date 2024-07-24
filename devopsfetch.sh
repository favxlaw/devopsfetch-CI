#!/bin/bash

port_info() {
    
    if [ -n "$1" ]; then
        echo -e "\nDetailed information for port $1:"
        ss -tlnp | grep "$1" | column -t
    else
        echo "Active Ports and Services:"
        ss -tlnp | column -t
    fi
}

docker_info() {
    
    if [ -n "$1" ]; then
        echo -e "\nDetailed information for container $1:"
        docker inspect "$1" | jq '.[] | {Id: .Id, Name: .Name, Image: .Image, Status: .State.Status, Ports: .NetworkSettings.Ports}'
    else
        echo "Docker Images and Containers:"
        docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Status}}" | column -t
    fi
}

nginx_info() {
    
    if [ -n "$1" ]; then
        echo -e "\nNginx Configuration for $1:"
        nginx -T 2>/dev/null | sed -n "/server_name $1/,/}/p" | column -t
    else
        echo "Nginx Domains and Ports:"
        nginx -T 2>/dev/null | grep server_name | awk '{print $2}' | sort -u | column -t
    fi
}

user_info() {
    
    if [ -n "$1" ]; then
        echo -e "\nDetailed information for user $1:"
        finger "$1" 2>/dev/null | column -t
    else
        echo "Users and Last Login Times:"
        lastlog | column -t
    fi
}

time_range_info() {
    if [ -n "$1" ] && [ -n "$2" ]; then
        start_time="$1"
        end_time="$2"
        echo "Activities from $start_time to $end_time:"
        journalctl --since "$start_time" --until "$end_time" | less
    else
        echo "Error: Both start and end times must be specified."
        echo "Usage: $0 -t <start_time> <end_time>"
        echo "Format: YYYY-MM-DD HH:MM:SS or HH:MM:SS"
    fi
}

help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -p [port]      Display active ports and services (optional: specific port)"
    echo "  -d [container] List Docker images and containers (optional: specific container)"
    echo "  -n [domain]    Display Nginx domains and ports (optional: specific domain)"
    echo "  -u [username]  List users and their last login times (optional: specific user)"
    echo "  -t <start_time> <end_time>  Display activities within a specified time range"
    echo "                 (Format: YYYY-MM-DD HH:MM:SS or HH:MM:SS)"
    echo "  -h             Display this help message"
}

main() {
    if [ $# -eq 0 ]; then
        port_info
        echo
        docker_info
        echo
        nginx_info
        echo
        user_info
    else
        while [ "$1" != "" ]; do
            case $1 in
                -p) 
                    shift
                    port_info "$1"
                    ;;
                -d)
                    shift
                    docker_info "$1"
                    ;;
                -n)
                    shift
                    nginx_info "$1"
                    ;;
                -u)
                    shift
                    user_info "$1"
                    ;;
                -t)
                    shift
                    if [ -n "$1" ] && [ -n "$2" ]; then
                        time_range_info "$1" "$2"
                        shift
                    else
                        echo "Error: Both start and end times must be specified for -t option."
                        echo "Usage: $0 -t <start_time> <end_time>"
                        exit 1
                    fi
                    ;;
                -h)
                    help
                    exit 0
                    ;;
                *)
                    echo "Invalid option: $1" >&2
                    exit 1
                    ;;
            esac
            shift
        done
    fi
}

main "$@"