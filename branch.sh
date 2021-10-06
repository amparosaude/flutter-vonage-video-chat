echo "---- CORE.APP"
cd core.app
git branch --show-current
git status -s
echo -e

echo "---- CORE.API"
cd ../core.api
git branch --show-current
git status -s
echo -e


echo "---- PORTAL.APP"
cd ../portal.app
git branch --show-current
git status -s
echo -e 

echo "---- PORTAL.API"
cd ../portal.api
git branch --show-current
git status -s
echo -e

