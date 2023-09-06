# jekyll

Developed based on [Ephesus Jekyll Theme](https://github.com/onepase/Ephesus), Author [Hakan Torun](https://hakan.io).

## Installation

Run local server:

```bash
$ yum install ruby ruby-devel -y
$ gem install bundler -v 2.3.26

$ cd ${project_path}
$ bundle install

$ cd ${project_path}
$ bundle exec jekyll clean
$ bundle exec jekyll build
$ bundle exec jekyll serve --trace -H 0.0.0.0 -P 4000
```

Navigate to `127.0.0.1:4000`.

Tags are created automatically under the /tags page.

To use a math formula in a post, use the mathjax:true tag in the post.

## License

This project is open source and available under the [MIT License](LICENSE.md).
