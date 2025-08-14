# NOTES

## To start BACKEND Server

```bash
cd backend
poetry shell
poetry run python manage.py runserver
```

Commands & Output:
<div style="border: 2px solid black; padding: 10px; margin: 10px; color: #000000ff; background-color: #ffffffff;">

jcabdi@JC-LPT:~/projects/new_work/new_crud_project/backend$ poetry shell

Spawning shell within /home/jcabdi/projects/new_work/new_crud_project/backend/.venv
jcabdi@JC-LPT:~/projects/new_work/new_crud_project/backend$ . /home/jcabdi/projects/new_work/new_crud_project/backend/.venv/bin/activate

(project-py3.12) jcabdi@JC-LPT:~/projects/new_work/new_crud_project/backend$ poetry run python manage.py runserver

Watching for file changes with StatReloader

Performing system checks...

System check identified no issues (0 silenced).

August 13, 2025 - 19:31:42

Django version 5.2.5, using settings 'django_folder.settings'

Starting development server at [http://127.0.0.1:8000/](http://127.0.0.1:8000/)

Quit the server with CONTROL-C.

WARNING: This is a development server. Do not use it in a production setting. Use a

production WSGI or ASGI server instead.

For more information on production servers see: <https://docs.djangoproject.com/en/5.2/howto/deployment/>
</div>

## To start FRONTEND Server

```bash
cd frontend
npm run dev -- --host
```

Commands & Output:
<div style="border: 2px solid black; padding: 10px; margin: 10px; color: #000000ff; background-color: #ffffffff;">
jcabdi@JC-LPT:~/projects/new_work/new_crud_project$ cd frontend/react_interface/
jcabdi@JC-LPT:~/projects/new_work/new_crud_project/frontend/react_interface$ npm run dev -- --host

> react_interface@0.0.0 dev
> vite --host

  VITE v7.1.2  ready in 93 ms

  ➜  Local:   [http://localhost:5173/](http://localhost:5173/)

  ➜  Network: [http://192.168.130.250:5173/](http://192.168.130.250:5173/)

  ➜  Network: [http://172.16.1.11:5173/](http://172.16.1.11:5173/)

  ➜  press h + enter to show help
</div>

## Default Credentials

Username:admin

Password:admin1234567890
