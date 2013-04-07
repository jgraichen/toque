
bash 'Be awesome!' do
  cwd node[:toque_pwd]
  code <<-EOH
    touch awesome
  EOH
  creates "#{node[:toque_pwd]}/awesome"
end
