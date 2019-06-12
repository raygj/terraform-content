# git connectivity check

## from Jenkins host:

`git ls-remote -h https://github.com/<URL of Git repo>`

## should return:

```jray@jenkins:~$ git ls-remote -h https://github.com/raygj/tfe-jenkins/
a6b4bf1b1181fccc89bc369905b55d07008ae516	refs/heads/master```

## if not, then error like this:

```jray@jenkins:~$ git ls-remote https://github.com/raygj/tfe-jenkins/tree/master/test-case-0
fatal: repository 'https://github.com/raygj/tfe-jenkins/tree/master/test-case-0/' not found```

# troubleshooting
- Git path cannot contain *tree/master*, must be in root
	- for instance */raygj/tfe-jenkins*

- otherwise use SSH to download zip, unzip locally and then proceed