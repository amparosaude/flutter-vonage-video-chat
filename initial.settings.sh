echo "CHECKOUT MASTER - CORE.APP"
cd core.app
git checkout master
echo "NPM INSTALL - CORE.APP"
npm install
echo -e

echo "CHECKOUT MASTER - CORE.API"
cd ../core.api
git checkout master
echo -e


echo "CHECKOUT MASTER - PORTAL.APP"
cd ../portal.app
git checkout master-refactor
echo "NPM INSTALL - PORTAL.APP"
npm install
echo -e 

echo "CHECKOUT MASTER - PORTAL.API"
cd ../portal.api
git checkout master
echo -e
