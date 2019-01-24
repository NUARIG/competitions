# if %w[development test].include?(Rails.env)
#   env_file = File.join(Rails.root, 'config', 'local_env.yml')
#   YAML.load(File.open(env_file)).each do |k, v|
#     next unless k == Rails.env
#     v.each do |variable, value|
#       ENV[variable.to_s] = value
#     end
#     break
#   end if File.exists?(env_file)
# end
