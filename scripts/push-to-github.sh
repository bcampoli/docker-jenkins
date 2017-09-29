url=$URL

call=$(curl -s "$url")

num=$(echo "$call" |  jq ".results | length")

let max=$num-1

for i in $(seq 0 $max);
  do
      val=$(echo "$call" | jq ".results[$i].name"| tr -d '"')
      if [ "$val" != "latest" ] ; then
        VERSION=$val
        break
      fi
done
echo "$VERSION"

git config --global push.default simple
git config --global user.email "$GITHUB_EMAIL"
git config --global user.name "$GITHUB_USERNAME"

cd ./github-repo-master
git branch
git checkout master
cd ..

git clone ./github-repo-master ./github-repo-modified
ls -la

cd github-repo-modified
ls -la
git branch

chmod 777 Dockerfile
perl -pi -e "s|FROM $DOCKER-HUB-REPO:[.^\S]+|FROM $DOCKER-HUB-REPO:$VERSION|" Dockerfile

cat Dockerfile

echo "$VERSION" > tag
DATE=`date '+%Y-%m-%d %H:%M:%S'`
echo "$DATE" > last_updated

git add --all
git commit -a -m "Updated to $DOCKER-HUB-REPO:${VERSION}, Date: $DATE"
