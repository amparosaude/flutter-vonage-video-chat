echo "CHECKOUT MASTER - CORE.APP"
cd core.app
git checkout master
git pull
echo -e

echo "CHECKOUT MASTER - CORE.API"
cd ../core.api
git checkout master
git pull
echo -e


echo "CHECKOUT MASTER - PORTAL.APP"
cd ../portal.app
git checkout main
git pull
echo -e 

echo "CHECKOUT MASTER - PORTAL.API"
cd ../portal.api
git checkout main
git pull
echo -e

