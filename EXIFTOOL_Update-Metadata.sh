#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 /path/to/photos"
  exit 1
fi

# The directory containing the photos, provided by argument
PHOTO_DIR=$1

# Check if the directory exists
if [ ! -d "$PHOTO_DIR" ]; then
  echo "Directory $PHOTO_DIR does not exist."
  exit 1
fi

# Configuration file path
CONF_FILE="metadata.conf"

# Check if configuration file exists
if [ ! -f "$CONF_FILE" ]; then
    echo "Configuration file not found! Please create a 'metadata.conf' file."
    exit 1
fi

# Function to safely extract values (ignores commented or missing fields)
get_field_value() {
    FIELD_NAME=$1
    VALUE=$(grep "^$FIELD_NAME=" "$CONF_FILE" | cut -d'=' -f2 | xargs) # Using 'xargs' to trim leading/trailing spaces
    echo "$VALUE"
}

# Extract values from configuration file (ignores commented-out lines)
ARTIST=$(get_field_value "Artist")
COPYRIGHT=$(get_field_value "Copyright")
KEYWORDS=$(get_field_value "Keywords")
GPS_LAT=$(get_field_value "GPS_LAT")
GPS_LAT_REF=$(get_field_value "GPS_LAT_REF")
GPS_LONG=$(get_field_value "GPS_LONG")
GPS_LONG_REF=$(get_field_value "GPS_LONG_REF")

# Prepare a summary of the fields that will be updated
echo "Metadata to be applied:"
[ -n "$ARTIST" ] && echo "Artist: $ARTIST"
[ -n "$COPYRIGHT" ] && echo "Copyright: $COPYRIGHT"
[ -n "$KEYWORDS" ] && echo "Keywords: $KEYWORDS"
[ -n "$GPS_LAT" ] && echo "GPS_LAT: $GPS_LAT"
[ -n "$GPS_LAT_REF" ] && echo "GPS_LAT_REF: $GPS_LAT_REF"
[ -n "$GPS_LONG" ] && echo "GPS_LONG: $GPS_LONG"
[ -n "$GPS_LONG_REF" ] && echo "GPS_LONG_REF: $GPS_LONG_REF"
echo ""

echo "To all photos in: $PHOTO_DIR"
echo ""
echo "Do you want to proceed? (y/n)"
read CONFIRM

# If user confirms, apply the metadata
if [ "$CONFIRM" = "y" ]; then
    # Build the exiftool command dynamically based on available fields
    EXIF_CMD="exiftool -v -overwrite_original"

    # Append the fields to the command only if they are set
    [ -n "$ARTIST" ] && EXIF_CMD="$EXIF_CMD -Artist=\"$ARTIST\""
    [ -n "$COPYRIGHT" ] && EXIF_CMD="$EXIF_CMD -Copyright=\"$COPYRIGHT\""
    [ -n "$KEYWORDS" ] && EXIF_CMD="$EXIF_CMD -Keywords=\"$KEYWORDS\""
	[ -n "$GPS_LAT" ] && EXIF_CMD="$EXIF_CMD -GPSLatitude=\"$GPS_LAT\""
	[ -n "$GPS_LAT_REF" ] && EXIF_CMD="$EXIF_CMD -GPSLatitudeRef=\"$GPS_LAT_REF\""
	[ -n "$GPS_LONG" ] && EXIF_CMD="$EXIF_CMD -GPSLatitudeRef=\"$GPS_LONG\""
	[ -n "$GPS_LONG_REF" ] && EXIF_CMD="$EXIF_CMD -GPSLongitudeRef=\"$GPS_LONG_REF\""

    echo "$EXIF_CMD"

    echo "$

    # Run the command
    eval "$EXIF_CMD \"$PHOTO_DIR\""

    # Summary of applied changes
    echo "Metadata applied successfully to photos in $PHOTO_DIR."
else
    echo "Operation cancelled."
fi