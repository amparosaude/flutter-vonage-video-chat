echo "CHECKOUT MASTER - CORE.APP"
cd core.app
git checkout portal-refactor
git pull
echo -e

echo "CHECKOUT MASTER - CORE.API"
cd ../core.api
git checkout portal-refactor
git pull
echo -e


echo "CHECKOUT MASTER - PORTAL.APP"
cd ../portal.app
git checkout master-refactor
git pull
echo -e 

echo "CHECKOUT MASTER - PORTAL.API"
cd ../portal.api
git checkout portal-refactor
git pull
echo -e

