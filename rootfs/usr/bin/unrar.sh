#!/usr/bin/env bash
# Used to automatically unrar a movie/show if needed
# Requires the following:
# * find
# * unrar

# rtorrent sends base path as first argument

# Settings
# Temp unrar dir. Put this on same filesystem so hardlinking is possible
TMP_DIR="/volume1/Warez/download/tmp"
ALLOWED_EXT=".mkv"


########## TEMP
#TR_TORRENT_DIR="/volume1/Warez/volume1/Warez/download/tv/sonarr"
#TR_TORRENT_NAME="The.Good.Doctor.S02E08.1080p.WEB.H264-METCON"
########## TEMP

TORRENT_PATH="${1}"
LABEL="${2}"

echo Downloaded $TORRENT_PATH with label ${LABEL}

if [[ ! -d "${TORRENT_PATH}" ]]; then
    # Not a directory so we don't care...
    # If torrent is a single archive we probably don't want to unpack it anyways
    echo ${TORRENT_PATH} is not a directory
    exit 0
fi

if [[ "${LABEL}" != "tv" ]] && [[ "${LABEL}" != "movies" ]]; then
    echo ${TORRENT_PATH} is not labeled as TV or movies
    exit 0
fi

function is_eligible_for_unpack() {
    for f in ${1}; do
        ELIGIBLE_CONTENTS=$(unrar v "$f" | grep ${ALLOWED_EXT})
        if [[ ! -z "${ELIGIBLE_CONTENTS}" ]]; then
            return 0
        fi
    done
    return 1
}

function unpack() {
    echo "Unraring ${1}"
    unrar x "$1" "${UNPACK_DIR}" >/dev/null

    mkdir -p "${FINISHED_DIR}"
    mv -un "${UNPACK_DIR}"/*${ALLOWED_EXT} "${FINISHED_DIR}"
}

RAR_FILES=$(find "${TORRENT_PATH}" -iname "*.rar" -type f)
UNPACK_DIR="${TMP_DIR}/$(basename ${TORRENT_PATH})"
FINISHED_DIR="${TORRENT_PATH}/"
if ! is_eligible_for_unpack "${RAR_FILES}"; then
    echo "Not eligible for unpack"
    exit 0
fi


mkdir -p "${UNPACK_DIR}"
for f in ${RAR_FILES}; do
    unpack "${f}"
done
if [[ ! -z "${RAR_FILES}" ]]; then
    rmdir "${UNPACK_DIR}"
fi