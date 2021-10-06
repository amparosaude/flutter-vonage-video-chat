echo "CORE.APP - portal-refactor"
cd core.app
git checkout portal-refactor
git pull
echo -e

echo "CORE.API - portal-refactor"
cd ../core.api
git checkout portal-refactor
git pull
echo -e


echo "PORTAL.APP - master-refactor"
cd ../portal.app
git checkout master-refactor
git pull
echo -e 

echo "PORTAL.API - portal-refactor"
cd ../portal.api
git checkout portal-refactor
git pull
echo -e

