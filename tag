#!/bin/bash
echo """
---------------------------
      Create tag
---------------------------
"""
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' 

RELEASE_TYPE=$1 

function select_release_type(){
	echo "Select release type : "
	echo "[ 1 ] major"
	echo "[ 2 ] minor"
	echo "[ 3 ] patch"

	read -p "> " INPUT_RELEASE_TYPE

	if [ "$INPUT_RELEASE_TYPE" = 1  ];then 
		RELEASE_TYPE="major"
	elif [ "$INPUT_RELEASE_TYPE" = 2  ];then 
		RELEASE_TYPE="minor"
	elif [ "$INPUT_RELEASE_TYPE" = 3  ];then 
		RELEASE_TYPE="patch"
	else 
		select_release_type
	fi 
}

# Get last version 
LAST_VERSION=`git describe --abbrev=0 --tags 2>/dev/null`
if [ ! "$LAST_VERSION" = "" ]; then 
	echo "Latest tag released : $LAST_VERSION"
	echo ""
fi 
LAST_VERSION=${LAST_VERSION:-'0.0.0'}

if [ -z "$RELEASE_TYPE" ];then 
	select_release_type
fi 
printf "Release type : ${CYAN}$RELEASE_TYPE${NC}\n"



#Get current hash and see if it already has a tag
GIT_COMMIT=`git rev-parse HEAD`
DESCRIBE_CURRENT_COMMIT=`git describe --contains $GIT_COMMIT 2>/dev/null`

if [ -z "$DESCRIBE_CURRENT_COMMIT" ];then 

	# Extract major.minor.patch version numbers 
	MAJOR="${LAST_VERSION%%.*}"; LAST_VERSION="${LAST_VERSION#*.}"
	MINOR="${LAST_VERSION%%.*}"; LAST_VERSION="${LAST_VERSION#*.}"
	PATCH="${LAST_VERSION%%.*}"; LAST_VERSION="${LAST_VERSION#*.}"

	# Increase version 
	if [ $RELEASE_TYPE = "major" ];then 
		MAJOR=$((MAJOR+1))
		MINOR=0
		PATCH=0
	elif [ $RELEASE_TYPE = "minor" ];then 
		MINOR=$((MINOR+1))
		PATCH=0
	elif [ $RELEASE_TYPE = "patch" ];then 
		PATCH=$((PATCH+1))
	fi 

	NEW_TAG="$MAJOR.$MINOR.$PATCH"

	# Validation 

	printf "Create and push tag with version : ${CYAN}$NEW_TAG${NC}\n"
	read -p "Do you want to continue ? [Y/n] " INPUT_VALIDATION
	if [ -z $INPUT_VALIDATION ] || [ $INPUT_VALIDATION = "y" ] || [ $INPUT_VALIDATION = "Y" ]; then

		# Create tag 
		echo "Create tag $NEW_TAG ..."
		git tag $NEW_TAG

		# Push 
		echo "Push tag $NEW_TAG ..."
		git push --tags

		printf "Tag ${CYAN}$NEW_TAG${NC} released "
	else 
		echo "Canceled"
	fi 
else 
	printf "${RED}Canceled${NC}\n"
	echo "A tag already exists on this commit"
	echo "Associated tag version : $DESCRIBE_CURRENT_COMMIT"
fi 

echo """
---------------------------
"""



