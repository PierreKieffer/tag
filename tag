#!/bin/bash

# Declare our globals
declare -A COLORS
COLORS[CYAN]="\033[0;36m"
COLORS[RED]="\033[0;31m"
COLORS[YELLOW]="\033[0;33m"
COLORS[NC]="\033[0m"

declare -A PARAMETERS

print_help_and_exit() {
    ## Print help page and then exit
    ##

    cat <<EOF >&2
Usage: tag [COMMAND]

Commands:
    -c, --create              [default] Create a new tag
    -l, --list {number}       List N existing tags
    -i, --inspect {tag}       Inspect a specfic tag
    -d, --delete {tag}        Delete a specfic tag
    -h, --help                Print this help and exit(0)

EOF
    exit 0
}

function print_if_set() {
    var="${1}"
    message="${2}"

    if [ -n "${var}" ]; then
        printf "${message}"
    fi
}

function select_release_type() {
    echo """Select release type :
[ 1 ] major
[ 2 ] minor
[ 3 ] patch"""
    read -p "> " input_release_type

    case "${input_release_type}" in
    1)
        PARAMETERS[RELEASE_TYPE]="major"
        ;;
    2)
        PARAMETERS[RELEASE_TYPE]="minor"
        ;;
    3)
        PARAMETERS[RELEASE_TYPE]="patch"
        ;;
    *)
        select_release_type
        ;;
    esac
}

function generate_tag_name() {
    last_version="${1}"

    # Extract major.minor.patch version numbers
    MAJOR="${last_version%%.*}"
    last_version="${last_version#*.}"
    MINOR="${last_version%%.*}"
    last_version="${last_version#*.}"
    PATCH="${last_version%%.*}"

    # Increase version
    case "${PARAMETERS[RELEASE_TYPE]}" in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
    *)
        select_release_type
        ;;
    esac

    echo "${MAJOR}.${MINOR}.${PATCH}"
}

function create_tag() {
    printf """
---------------------------
      Create tag
---------------------------

"""
    # Get last version, scan tags across all known branches
    last_version=$(git describe --abbrev=0 --tags $(git rev-list --tags --max-count=1) 2>/dev/null)
    if [ -n "${last_version}" ]; then
        printf "Latest tag released : ${last_version}\n"
        printf "\n"
    fi
    last_version=${last_version:-'0.0.0'}

    if [ -z "${PARAMETERS[RELEASE_TYPE]}" ]; then
        select_release_type
    fi
    printf "Release type : ${COLORS[CYAN]}${PARAMETERS[RELEASE_TYPE]}${COLORS[NC]}\n"

    #Get current hash and see if it already has a tag
    GIT_COMMIT=$(git rev-parse HEAD)
    DESCRIBE_CURRENT_COMMIT=$(git describe --contains ${GIT_COMMIT} 2>/dev/null)

    if [ -n "${DESCRIBE_CURRENT_COMMIT}" ]; then
        printf "${COLORS[RED]}Canceled${COLORS[NC]}\n"
        printf "A tag already exists on this commit\n"
        printf "Associated tag version : ${DESCRIBE_CURRENT_COMMIT}\n"
        exit 1
    fi

    new_tag=$(generate_tag_name ${LAST_VERSION})

    # Validation
    printf "Create and push tag with version : ${COLORS[CYAN]}${new_tag}${COLORS[NC]}\n"
    read -p "Do you want to continue ? [Y/n] " input_validation
    if [ -z ${input_validation} ] || [ ${input_validation} = "y" ] || [ ${input_validation} = "Y" ]; then

        # Create tag
        printf "Create tag ${new_tag} ...\n"
        git tag $new_tag

        # Push
        printf "Push tag ${new_tag} ...\n"
        git push --tags

        printf "Tag ${COLORS[CYAN]}${new_tag}${COLORS[NC]} released\n"
    else
        printf "Canceled\n"
    fi

    printf """
---------------------------

"""
}

function list_tags() {
    printf """
----------------------------
          List tag
----------------------------

"""
    printf "Listing last ${COLORS[CYAN]}${PARAMETERS[LIST_N]}${COLORS[NC]} tags :\n\n"

    git tag --sort=-version:refname | head -n ${PARAMETERS[LIST_N]}
    printf "...\n"

    printf """
----------------------------

"""
}

function inspect_tag() {
    printf """
---------------------------
        Inspect tag
---------------------------

"""
    description=$(git tag --list ${PARAMETERS[TARGET_TAG]} -n100 | sed 's/  */ /g' | cut -d' ' -f2-)
    c_hash=$(git show ${PARAMETERS[TARGET_TAG]} --pretty=fuller | grep "commit " | sed 's/  */ /g' | cut -d' ' -f2-)
    t_author=$(git log -1 --format="%cn" "${c_hash}")
    t_date=$(git log -1 --format="%cs" "${c_hash}")
    c_author=$(git log -1 --format="%an" "${c_hash}")
    c_date=$(git log -1 --format="%as" "${c_hash}")
    c_subject=$(git log -1 --format="%s" "${c_hash}")
    c_body=$(git log -1 --format="%b" "${c_hash}")
    c_branch="$(git log -1 --format="%D" "${c_hash}" | grep -oE '[^ ]+$')"
    if [ "${c_branch}" == "${PARAMETERS[TARGET_TAG]}" ]; then
        c_branch=""
    fi

    printf "> Tag: ${COLORS[CYAN]}${PARAMETERS[TARGET_TAG]}${COLORS[NC]}\n"
    print_if_set "${t_date}" "  > Date: ${COLORS[CYAN]}${t_date}${COLORS[NC]}\n"
    print_if_set "${t_author}" "  > Author: ${COLORS[CYAN]}${t_author}${COLORS[NC]}\n"
    print_if_set "${description}" "  > description: ${COLORS[CYAN]}${description}${COLORS[NC]}\n"
    printf "\n"
    printf "> Commit: ${COLORS[CYAN]}${c_hash}${COLORS[NC]}\n"
    print_if_set "${c_date}" "  > Date: ${COLORS[CYAN]}${c_date}${COLORS[NC]}\n"
    print_if_set "${c_author}" "  > Author: ${COLORS[CYAN]}${c_author}${COLORS[NC]}\n"
    print_if_set "${c_subject}" "  > Subject: ${COLORS[CYAN]}${c_subject}${COLORS[NC]}\n"
    print_if_set "${c_body}" "  > Body: ${COLORS[CYAN]}${c_body}${COLORS[NC]}\n"
    printf """
---------------------------
"""
}

function delete_tag() {
    printf """
----------------------------
         Delete tag
----------------------------

"""

    # Validation
    printf "Delete local and remote tag : ${COLORS[CYAN]}${PARAMETERS[TARGET_TAG]}${COLORS[NC]}\n"
    read -p "Do you want to continue ? [Y/n] " input_validation
    if [ -z ${input_validation} ] || [ ${input_validation} = "y" ] || [ ${input_validation} = "Y" ]; then

        # Delete local tag
        printf "Delete local tag ${PARAMETERS[TARGET_TAG]} ...\n"
        git tag -d "${PARAMETERS[TARGET_TAG]}"

        # Delete remote tag
        printf "Delete remote tag ${PARAMETERS[TARGET_TAG]} ...\n"
        git push --delete origin "${PARAMETERS[TARGET_TAG]}"

        printf "Tag ${COLORS[CYAN]}${PARAMETERS[TARGET_TAG]}${COLORS[NC]} deleted\n"
    else
        printf "Canceled\n"
    fi

    printf """
----------------------------
"""
}

parse_arguments() {
    PARAMETERS[MODE]="create"

    # Parse all command line arguments
    while [[ $# -gt 0 ]]; do
        key="${1}"
        case "${key}" in
        -c | --create)
            PARAMETERS[MODE]="create"
            shift
            ;;
        -l | --list)
            PARAMETERS[MODE]="list"
            shift
            if [ -n "${1}" ] && [[ "${1}" =~ ^[0-9]+$ ]]; then
                PARAMETERS[LIST_N]="${1}"
                shift
            else
                PARAMETERS[LIST_N]=10
                printf -- "${COLORS[RED]}--list parameter not followed by a number. Aborting${COLORS[NC]}\n"
                exit 1
            fi
            ;;
        -i | --inspect)
            PARAMETERS[MODE]="inspect"
            shift
            if [ -n "${1}" ] && ! [[ "${1}" = "-"* ]]; then
                PARAMETERS[TARGET_TAG]=$1
                shift
            else
                printf -- "${COLORS[RED]}--inspect parameter not followed by a tag. Aborting${COLORS[NC]}\n"
                exit 1
            fi
            ;;
        -d | --delete)
            PARAMETERS[MODE]="delete"
            shift
            if [ -n "${1}" ] && ! [[ "${1}" = "-"* ]]; then
                PARAMETERS[TARGET_TAG]=$1
                shift
            else
                printf -- "${COLORS[RED]}--delete parameter not followed by a tag. Aborting${COLORS[NC]}\n"
                exit 1
            fi
            ;;
        -h | --help)
            print_help_and_exit
            ;;
        *)
            if [ -z "${PARAMETERS[RELEASE_TYPE]}" ]; then
                if [ "${key}" == "major" ] || [ "${key}" == "minor" ] || [ "${key}" == "patch" ]; then
                    PARAMETERS[RELEASE_TYPE]="${key}"
                    shift
                else
                    printf -- "${COLORS[RED]}Release type must be one of 'major', 'minor' or 'patch', not '${key}'. Aborting${COLORS[NC]}\n"
                    exit 1
                fi
            else
                print_help_and_exit
            fi
            ;;
        esac
    done
}

function main() {
    parse_arguments $@

    case "${PARAMETERS[MODE]}" in
    create)
        create_tag
        ;;
    list)
        list_tags
        ;;
    inspect)
        inspect_tag
        ;;
    delete)
        delete_tag
        ;;
    *)
        print_help_and_exit
        ;;
    esac
}

main $@
