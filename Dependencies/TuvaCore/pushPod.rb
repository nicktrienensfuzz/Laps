#!/usr/bin/env ruby
tag = ARGV[0]
oldtag="0.0.14"
puts tag

cmd = "sed -i '' -e 's/#{oldtag}/#{tag}/' *.podspec"
value = system( cmd )

cmd = "sed -i '' -e 's/#{oldtag}/#{tag}/' *.rb"
value = system( cmd )

# cmd = "git status"
# value = system( cmd )
cmd = "git add pushPod.rb"
value = system( cmd )

cmd = "git add *.podspec"
value = system( cmd )

cmd = "git commit -m '[Pod push] auto update podspec'"
value = system( cmd )

cmd = "git push"
value = system( cmd )


#gitcommands
cmd = "git status"
value = system( cmd )

cmd = "git tag -a '#{tag}' -m 'auto tag' --force"
value = system( cmd )

cmd = "git push --tags --force"
value = system( cmd )

cmd = "pod lib lint *.podspec --allow-warnings --sources=fuzz-productions"
value = system( cmd )

cmd = "pod repo push fuzz-productions *.podspec --allow-warnings --sources=fuzz-productions"
value = system( cmd )
