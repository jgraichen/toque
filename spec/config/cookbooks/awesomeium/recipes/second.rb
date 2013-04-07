
bash 'Be awesome again!' do
  cwd node[:toque_pwd]
  code <<-EOH
    rm -f awesome
  EOH
end
