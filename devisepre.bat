IF "%devise_dir%"=="" GOTO END
copy "%devise_dir%\app\controllers\devise\sessions_controller.rb" "devise views\sessions\sessions_controller.rb"
copy "%devise_dir%\app\views\devise\sessions\new.iphone.erb" "devise views\sessions\new.iphone.erb"
copy "%devise_dir%\app\views\devise\sessions\new.html.erb" "devise views\sessions\new.html.erb"
copy "%devise_dir%\app\controllers\devise\registrations_controller.rb" "devise views\registrations\registrations_controller.rb"
copy "%devise_dir%\app\views\devise\registrations\new.html.erb" "devise views\registrations\new.html.erb"
copy "%devise_dir%\app\views\devise\registrations\edit.html.erb" "devise views\registrations\edit.html.erb"
copy "%devise_dir%\app\views\devise\shared\_links.erb" "devise views\shared\_links.erb"
GOTO END2
:END
ECHO "devise_dir environment variable must be set, e.g. c:\Ruby192\lib\ruby\gems\1.9.1\gems\devise-1.1.7"
:END2
