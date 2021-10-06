
ip="192.168.1.42"

sed -i "s/localhost/$ip/" core.app/.env

sed -i "s/PORTAL_ROOT_API=http:\/\/api_portal/PORTAL_ROOT_API=http:\/\/$ip/" core.api/.env
sed -i "s/localhost/$ip/" core.api/.env

sed -i "s/localhost/$ip/" portal.app/.env

sed -i "s/CORE_API_LOCATION=http:\/\/api_core/CORE_API_LOCATION=http:\/\/$ip/" portal.api/.env
sed -i "s/localhost/$ip/" portal.api/.env
