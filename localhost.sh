
ip="192.168.1.42"

sed -i "s/$ip/localhost/" core.app/.env

sed -i "s/PORTAL_ROOT_API=http:\/\/$ip/PORTAL_ROOT_API=http:\/\/api_portal/" core.api/.env
sed -i "s/$ip/localhost/" core.api/.env

sed -i "s/$ip/localhost/" portal.app/.env

sed -i "s/CORE_API_LOCATION=http:\/\/$ip/CORE_API_LOCATION=http:\/\/api_core/" portal.api/.env
sed -i "s/$ip/localhost/" portal.api/.env
