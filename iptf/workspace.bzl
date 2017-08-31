load('@org_tensorflow//tensorflow:workspace.bzl', 'tf_workspace')
load('@org_tensorflow//third_party/py:python_configure.bzl', 'python_configure')
load("@io_bazel_rules_go//go:def.bzl", "go_repositories", "go_repository")
#load("@io_bazel_rules_go//go:def.bzl", "go_rules_dependencies", "go_register_toolchains", "go_repository")
load('@org_tensorflow//tensorflow:workspace.bzl', 'patched_http_archive')
load("@org_tensorflow_tensorboard//third_party:workspace.bzl", "tensorboard_workspace")
load("@io_bazel_rules_closure//closure:defs.bzl", "closure_repositories")


def iptf_workspace():
  python_configure(name = "local_config_python")

  closure_repositories()
  tf_workspace(path_prefix = "", tf_repo_name = "org_tensorflow")
  tensorboard_workspace()

  go_repositories()

  #print("alskdfjasdasdf")
  #go_rules_dependencies()
  #go_register_toolchains()

  patched_http_archive(
      name = "protobuf",
      urls = [
          "http://mirror.bazel.build/github.com/google/protobuf/archive/2b7430d96aeff2bb624c8d52182ff5e4b9f7f18a.tar.gz",
          "https://github.com/google/protobuf/archive/2b7430d96aeff2bb624c8d52182ff5e4b9f7f18a.tar.gz",
      ],
      sha256 = "e5d3d4e227a0f7afb8745df049bbd4d55474b158ca5aaa2a0e31099af24be1d0",
      strip_prefix = "protobuf-2b7430d96aeff2bb624c8d52182ff5e4b9f7f18a",
      # TODO: remove patching when tensorflow stops linking same protos into
      #       multiple shared libraries loaded in runtime by python.
      #       This patch fixes a runtime crash when tensorflow is compiled
      #       with clang -O2 on Linux (see https://github.com/tensorflow/tensorflow/issues/8394)
      patch_file = str("@org_tensorflow//third_party/protobuf:add_noinlines.patch"),
  )

  native.new_http_archive(
    name = "d3",
    build_file = "bower.BUILD",
    url = "https://github.com/mbostock-bower/d3-bower/archive/v3.5.15.tar.gz",
    strip_prefix = "d3-bower-3.5.15",
  )

  native.new_http_archive(
    name = "dagre",
    build_file = "bower.BUILD",
    url = "https://github.com/cpettitt/dagre/archive/v0.7.4.tar.gz",
    strip_prefix = "dagre-0.7.4",
  )

  native.new_http_archive(
    name = "es6_promise",
    build_file = "bower.BUILD",
    url = "https://github.com/components/es6-promise/archive/v2.1.0.tar.gz",
    strip_prefix = "es6-promise-2.1.0",
  )

  native.new_http_archive(
    name = "font_roboto",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/font-roboto/archive/v1.0.1.tar.gz",
    strip_prefix = "font-roboto-1.0.1",
  )

  native.new_http_archive(
    name = "graphlib",
    build_file = "bower.BUILD",
    url = "https://github.com/cpettitt/graphlib/archive/v1.0.7.tar.gz",
    strip_prefix = "graphlib-1.0.7",
  )

  native.new_http_archive(
    name = "iron_a11y_announcer",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/iron-a11y-announcer/archive/v1.0.5.tar.gz",
    strip_prefix = "iron-a11y-announcer-1.0.5",
  )

  native.new_http_archive(
    name = "iron_a11y_keys_behavior",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/iron-a11y-keys-behavior/archive/v1.1.8.tar.gz",
    strip_prefix = "iron-a11y-keys-behavior-1.1.8",
  )

  native.new_http_archive(
    name = "iron_ajax",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/iron-ajax/archive/v1.2.0.tar.gz",
    strip_prefix = "iron-ajax-1.2.0",
  )

  native.new_http_archive(
    name = "iron_autogrow_textarea",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/iron-autogrow-textarea/archive/v1.0.12.tar.gz",
    strip_prefix = "iron-autogrow-textarea-1.0.12",
  )

  native.new_http_archive(
    name = "iron_behaviors",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/iron-behaviors/archive/v1.0.17.tar.gz",
    strip_prefix = "iron-behaviors-1.0.17",
  )

  native.new_http_archive(
    name = "iron_checked_element_behavior",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/iron-checked-element-behavior/archive/v1.0.4.tar.gz",
    strip_prefix = "iron-checked-element-behavior-1.0.4",
  )

  native.new_http_archive(
    name = "iron_collapse",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/iron-collapse/archive/v1.0.8.tar.gz",
    strip_prefix = "iron-collapse-1.0.8",
  )

  native.new_http_archive(
    name = "iron_dropdown",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/iron-dropdown/archive/v1.4.0.tar.gz",
    strip_prefix = "iron-dropdown-1.4.0",
  )

  native.new_http_archive(
    name = "iron_fit_behavior",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/iron-fit-behavior/archive/v1.2.5.tar.gz",
    strip_prefix = "iron-fit-behavior-1.2.5",
  )

  native.new_http_archive(
    name = "iron_flex_layout",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/iron-flex-layout/archive/v1.3.0.tar.gz",
    strip_prefix = "iron-flex-layout-1.3.0",
  )

  native.new_http_archive(
    name = "iron_form_element_behavior",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/iron-form-element-behavior/archive/v1.0.6.tar.gz",
    strip_prefix = "iron-form-element-behavior-1.0.6",
  )

  native.new_http_archive(
    name = "iron_icon",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/iron-icon/archive/v1.0.11.tar.gz",
    strip_prefix = "iron-icon-1.0.11",
  )

  native.new_http_archive(
    name = "iron_icons",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/iron-icons/archive/v1.1.3.tar.gz",
    strip_prefix = "iron-icons-1.1.3",
  )

  native.new_http_archive(
    name = "iron_iconset_svg",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/iron-iconset-svg/archive/v1.1.0.tar.gz",
    strip_prefix = "iron-iconset-svg-1.1.0",
  )

  native.new_http_archive(
    name = "iron_input",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/iron-input/archive/1.0.10.tar.gz",
    strip_prefix = "iron-input-1.0.10",
  )

  native.new_http_archive(
    name = "iron_list",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/iron-list/archive/v1.3.9.tar.gz",
    strip_prefix = "iron-list-1.3.9",
  )

  native.new_http_archive(
    name = "iron_menu_behavior",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/iron-menu-behavior/archive/v1.1.10.tar.gz",
    strip_prefix = "iron-menu-behavior-1.1.10",
  )

  native.new_http_archive(
    name = "iron_meta",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/iron-meta/archive/v1.1.1.tar.gz",
    strip_prefix = "iron-meta-1.1.1",
  )

  native.new_http_archive(
    name = "iron_overlay_behavior",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/iron-overlay-behavior/archive/v1.10.1.tar.gz",
    strip_prefix = "iron-overlay-behavior-1.10.1",
  )

  native.new_http_archive(
    name = "iron_range_behavior",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/iron-range-behavior/archive/v1.0.4.tar.gz",
    strip_prefix = "iron-range-behavior-1.0.4",
  )

  native.new_http_archive(
    name = "iron_resizable_behavior",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/iron-resizable-behavior/archive/v1.0.3.tar.gz",
    strip_prefix = "iron-resizable-behavior-1.0.3",
  )

  native.new_http_archive(
    name = "iron_scroll_target_behavior",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/iron-scroll-target-behavior/archive/v1.0.3.tar.gz",
    strip_prefix = "iron-scroll-target-behavior-1.0.3",
  )

  native.new_http_archive(
    name = "iron_selector",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/iron-selector/archive/v1.5.2.tar.gz",
    strip_prefix = "iron-selector-1.5.2",
  )

  native.new_http_archive(
    name = "iron_validatable_behavior",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/iron-validatable-behavior/archive/v1.1.1.tar.gz",
    strip_prefix = "iron-validatable-behavior-1.1.1",
  )

  native.new_http_archive(
    name = "lodash",
    build_file = "bower.BUILD",
    url = "https://github.com/lodash/lodash/archive/3.8.0.tar.gz",
    strip_prefix = "lodash-3.8.0",
  )

  native.new_http_archive(
    name = "neon_animation",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/neon-animation/archive/v1.2.2.tar.gz",
    strip_prefix = "neon-animation-1.2.2",
  )

  native.http_file(
    name = "numericjs_numeric_min_js",
    url = "https://cdnjs.cloudflare.com/ajax/libs/numeric/1.2.6/numeric.min.js",
  )

  native.new_http_archive(
    name = "paper_behaviors",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-behaviors/archive/v1.0.12.tar.gz",
    strip_prefix = "paper-behaviors-1.0.12",
  )

  native.new_http_archive(
    name = "paper_button",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-button/archive/v1.0.11.tar.gz",
    strip_prefix = "paper-button-1.0.11",
  )

  native.new_http_archive(
    name = "paper_checkbox",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-checkbox/archive/v1.4.0.tar.gz",
    strip_prefix = "paper-checkbox-1.4.0",
  )

  native.new_http_archive(
    name = "paper_dialog",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-dialog/archive/v1.0.4.tar.gz",
    strip_prefix = "paper-dialog-1.0.4",
  )

  native.new_http_archive(
    name = "paper_dialog_behavior",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-dialog-behavior/archive/v1.2.5.tar.gz",
    strip_prefix = "paper-dialog-behavior-1.2.5",
  )

  native.new_http_archive(
    name = "paper_dialog_scrollable",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-dialog-scrollable/archive/1.1.5.tar.gz",
    strip_prefix = "paper-dialog-scrollable-1.1.5",
  )

  native.new_http_archive(
    name = "paper_dropdown_menu",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-dropdown-menu/archive/v1.4.0.tar.gz",
    strip_prefix = "paper-dropdown-menu-1.4.0",
  )

  native.new_http_archive(
    name = "paper_header_panel",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-header-panel/archive/v1.1.4.tar.gz",
    strip_prefix = "paper-header-panel-1.1.4",
  )

  native.new_http_archive(
    name = "paper_icon_button",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-icon-button/archive/v1.1.3.tar.gz",
    strip_prefix = "paper-icon-button-1.1.3",
  )

  native.new_http_archive(
    name = "paper_input",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-input/archive/v1.1.18.tar.gz",
    strip_prefix = "paper-input-1.1.18",
  )

  native.new_http_archive(
    name = "paper_item",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-item/archive/v1.1.4.tar.gz",
    strip_prefix = "paper-item-1.1.4",
  )

  native.new_http_archive(
    name = "paper_listbox",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-listbox/archive/v1.1.2.tar.gz",
    strip_prefix = "paper-listbox-1.1.2",
  )

  native.new_http_archive(
    name = "paper_material",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-material/archive/v1.0.6.tar.gz",
    strip_prefix = "paper-material-1.0.6",
  )

  native.new_http_archive(
    name = "paper_menu",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-menu/archive/v1.2.2.tar.gz",
    strip_prefix = "paper-menu-1.2.2",
  )

  native.new_http_archive(
    name = "paper_menu_button",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-menu-button/archive/v1.5.1.tar.gz",
    strip_prefix = "paper-menu-button-1.5.1",
  )

  native.new_http_archive(
    name = "paper_progress",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-progress/archive/v1.0.9.tar.gz",
    strip_prefix = "paper-progress-1.0.9",
  )

  native.new_http_archive(
    name = "paper_radio_button",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-radio-button/archive/v1.1.2.tar.gz",
    strip_prefix = "paper-radio-button-1.1.2",
  )

  native.new_http_archive(
    name = "paper_radio_group",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-radio-group/archive/v1.0.9.tar.gz",
    strip_prefix = "paper-radio-group-1.0.9",
  )

  native.new_http_archive(
    name = "paper_ripple",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-ripple/archive/v1.0.5.tar.gz",
    strip_prefix = "paper-ripple-1.0.5",
  )

  native.new_http_archive(
    name = "paper_slider",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-slider/archive/v1.0.10.tar.gz",
    strip_prefix = "paper-slider-1.0.10",
  )

  native.new_http_archive(
    name = "paper_spinner",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-spinner/archive/v1.1.1.tar.gz",
    strip_prefix = "paper-spinner-1.1.1",
  )

  native.new_http_archive(
    name = "paper_styles",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-styles/archive/v1.1.4.tar.gz",
    strip_prefix = "paper-styles-1.1.4",
  )

  native.new_http_archive(
    name = "paper_tabs",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-tabs/archive/v1.7.0.tar.gz",
    strip_prefix = "paper-tabs-1.7.0",
  )

  native.new_http_archive(
    name = "paper_toast",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-toast/archive/v1.3.0.tar.gz",
    strip_prefix = "paper-toast-1.3.0",
  )

  native.new_http_archive(
    name = "paper_toggle_button",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-toggle-button/archive/v1.2.0.tar.gz",
    strip_prefix = "paper-toggle-button-1.2.0",
  )

  native.new_http_archive(
    name = "paper_toolbar",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-toolbar/archive/v1.1.4.tar.gz",
    strip_prefix = "paper-toolbar-1.1.4",
  )

  native.new_http_archive(
    name = "paper_tooltip",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerelements/paper-tooltip/archive/v1.1.2.tar.gz",
    strip_prefix = "paper-tooltip-1.1.2",
  )

  native.new_http_archive(
    name = "plottable",
    build_file = "bower.BUILD",
    url = "https://github.com/palantir/plottable/archive/v1.16.1.tar.gz",
    strip_prefix = "plottable-1.16.1",
  )

  native.new_http_archive(
    name = "polymer",
    build_file = "bower.BUILD",
    url = "https://github.com/polymer/polymer/archive/v1.7.0.tar.gz",
    strip_prefix = "polymer-1.7.0",
  )

  native.new_http_archive(
    name = "promise_polyfill",
    build_file = "bower.BUILD",
    url = "https://github.com/polymerlabs/promise-polyfill/archive/v1.0.0.tar.gz",
    strip_prefix = "promise-polyfill-1.0.0",
  )

  native.http_file(
    name = "three_js_three_min_js",
    url = "https://raw.githubusercontent.com/mrdoob/three.js/r77/build/three.min.js",
  )

  native.http_file(
    name = "three_js_orbitcontrols_js",
    url = "https://raw.githubusercontent.com/mrdoob/three.js/r77/examples/js/controls/OrbitControls.js",
  )

  native.new_http_archive(
    name = "web_animations_js",
    build_file = "bower.BUILD",
    url = "https://github.com/web-animations/web-animations-js/archive/2.2.1.tar.gz",
    strip_prefix = "web-animations-js-2.2.1",
  )

  native.new_http_archive(
    name = "webcomponentsjs",
    build_file = "bower.BUILD",
    url = "https://github.com/webcomponents/webcomponentsjs/archive/v0.7.22.tar.gz",
    strip_prefix = "webcomponentsjs-0.7.22",
  )

  native.http_file(
    name = "weblas_weblas_js",
    url = "https://raw.githubusercontent.com/waylonflinn/weblas/v0.9.0/dist/weblas.js",
  )

  native.new_git_repository(
      name = "com_github_whyrusleeping_go_notifier",
      build_file = "third_party/com_github_whyrusleeping_go_notifier.bazel",
      commit = "8d81c69ca17629313f595a9f379cf9b10e6a540b",
      remote = "https://github.com/whyrusleeping/go-notifier",
  )

  go_repository(
      name = "com_github_Kubuxu_go_os_helper",
      commit = "3d3fc2fb493d8d889dddd5a4524283ac2faa4732",
      importpath = "github.com/Kubuxu/go-os-helper",
  )
  go_repository(
      name = "com_github_agl_ed25519",
      commit = "5312a61534124124185d41f09206b9fef1d88403",
      importpath = "github.com/agl/ed25519",
  )
  go_repository(
      name = "com_github_beorn7_perks",
      commit = "4c0e84591b9aa9e6dcfdf3e020114cd81f89d5f9",
      importpath = "github.com/beorn7/perks",
  )
  go_repository(
      name = "com_github_blang_semver",
      commit = "2ee87856327ba09384cabd113bc6b5d174e9ec0f",
      importpath = "github.com/blang/semver",
  )
  go_repository(
      name = "com_github_bren2010_proquint",
      commit = "38337c27106d8f06e9b5cddc6df973ceece1c8ea",
      importpath = "github.com/bren2010/proquint",
  )
  go_repository(
      name = "com_github_btcsuite_btcd",
      commit = "45ea940039d9685a38a8996867672fd21ee9c0f2",
      importpath = "github.com/btcsuite/btcd",
  )
  go_repository(
      name = "com_github_cenkalti_backoff",
      commit = "61153c768f31ee5f130071d08fc82b85208528de",
      importpath = "github.com/cenkalti/backoff",
  )
  go_repository(
      name = "com_github_cheggaaa_pb",
      commit = "0d6285554e726cc0620cbecc7e6969c945dcc63b",
      importpath = "github.com/cheggaaa/pb",
  )
  go_repository(
      name = "com_github_codegangsta_cli",
      commit = "f017f86fccc5a039a98f23311f34fdf78b014f78",
      importpath = "github.com/codegangsta/cli",
  )
  go_repository(
      name = "com_github_coreos_go_semver",
      commit = "1817cd4bea52af76542157eeabd74b057d1a199e",
      importpath = "github.com/coreos/go-semver",
  )
  go_repository(
      name = "com_github_davidlazar_go_crypto",
      commit = "dcfb0a7ac018a248366f96bcd8a2f8c805d7b268",
      importpath = "github.com/davidlazar/go-crypto",
  )
  go_repository(
      name = "com_github_docker_spdystream",
      commit = "ed496381df8283605c435b86d4fdd6f4f20b8c6e",
      importpath = "github.com/docker/spdystream",
  )
  go_repository(
      name = "com_github_dustin_go_humanize",
      commit = "259d2a102b871d17f30e3cd9881a642961a1e486",
      importpath = "github.com/dustin/go-humanize",
  )
  go_repository(
      name = "com_github_facebookgo_atomicfile",
      commit = "2de1f203e7d5e386a6833233882782932729f27e",
      importpath = "github.com/facebookgo/atomicfile",
  )
  go_repository(
      name = "com_github_fd_go_nat",
      commit = "dcaf50131e4810440bed2cbb6f7f32c4f4cc95dd",
      importpath = "github.com/fd/go-nat",
  )
  go_repository(
      name = "com_github_gogo_protobuf",
      commit = "fcdc5011193ff531a548e9b0301828d5a5b97fd8",
      importpath = "github.com/gogo/protobuf",
  )
  go_repository(
      name = "com_github_golang_protobuf",
      commit = "ab9f9a6dab164b7d1246e0e688b0ab7b94d8553e",
      importpath = "github.com/golang/protobuf",
  )
  go_repository(
      name = "com_github_golang_snappy",
      commit = "553a641470496b2327abcac10b36396bd98e45c9",
      importpath = "github.com/golang/snappy",
  )
  go_repository(
      name = "com_github_gorilla_websocket",
      commit = "a69d9f6de432e2c6b296a947d8a5ee88f68522cf",
      importpath = "github.com/gorilla/websocket",
  )
  go_repository(
      name = "com_github_gxed_bbloom",
      commit = "6c7292d0e0050d4187fb67f264cfa1b0a147c733",
      importpath = "github.com/gxed/bbloom",
  )
  go_repository(
      name = "com_github_gxed_client_golang",
      commit = "5592ec3785b07b959fd7bdaedcf561f1b75b90bd",
      importpath = "github.com/gxed/client_golang",
  )
  go_repository(
      name = "com_github_hashicorp_golang_lru",
      commit = "0a025b7e63adc15a622f29b0b2c4c3848243bbf6",
      importpath = "github.com/hashicorp/golang-lru",
  )
  go_repository(
      name = "com_github_hashicorp_yamux",
      commit = "d1caa6c97c9fc1cc9e83bbe34d0603f9ff0ce8bd",
      importpath = "github.com/hashicorp/yamux",
  )
  go_repository(
      name = "com_github_huin_goupnp",
      commit = "9b81a7424f2384e4df098d4ac9096f9ed9d8ef95",
      importpath = "github.com/huin/goupnp",
  )
  go_repository(
      name = "com_github_ipfs_dir_index_html",
      commit = "66cbbeb90c9428feb03ffb2e304aa803c8777be3",
      importpath = "github.com/ipfs/dir-index-html",
  )
  go_repository(
      name = "com_github_ipfs_go_block_format",
      commit = "3b0dbd6dcfc482b52cc2047854276f2388b81675",
      importpath = "github.com/ipfs/go-block-format",
  )
  go_repository(
      name = "com_github_ipfs_go_cid",
      commit = "5652e6f751d6c929f69c58090a337b7c4fe2048f",
      importpath = "github.com/ipfs/go-cid",
  )
  go_repository(
      name = "com_github_ipfs_go_datastore",
      commit = "e8521f97048a5b92f2dfd74b413928cb7d7cce1c",
      importpath = "github.com/ipfs/go-datastore",
  )
  go_repository(
      name = "com_github_ipfs_go_ds_flatfs",
      commit = "5f5a12b0b5179993edc42df6bf44bc6120c5eb84",
      importpath = "github.com/ipfs/go-ds-flatfs",
  )
  go_repository(
      name = "com_github_ipfs_go_ds_leveldb",
      commit = "0bd8ab0a53a8a353f156f9cb1300ed32750998f3",
      importpath = "github.com/ipfs/go-ds-leveldb",
  )
  go_repository(
      name = "com_github_ipfs_go_ds_measure",
      commit = "849954870d3cfe4de210c22ed8ce2ed3b6bfc4e7",
      importpath = "github.com/ipfs/go-ds-measure",
  )
  go_repository(
      name = "com_github_ipfs_go_ipfs_api",
      commit = "1c4abbe587f0f68fee5fcecf741a45dbe3d7bc12",
      importpath = "github.com/ipfs/go-ipfs-api",
  )
  go_repository(
      name = "com_github_ipfs_go_ipfs_util",
      commit = "ca91b45d2e776e6e066151f7b65a3984c87e9fbb",
      importpath = "github.com/ipfs/go-ipfs-util",
  )
  go_repository(
      name = "com_github_ipfs_go_ipld_cbor",
      commit = "225786aefca1af0e1061de955ab6b489f39a6eb8",
      importpath = "github.com/ipfs/go-ipld-cbor",
  )
  go_repository(
      name = "com_github_ipfs_go_ipld_format",
      commit = "5804fc9c967013790b1866cbb4975a24e0ec2aae",
      importpath = "github.com/ipfs/go-ipld-format",
  )
  go_repository(
      name = "com_github_ipfs_go_log",
      commit = "48d644b006ba26f1793bffc46396e981801078e3",
      importpath = "github.com/ipfs/go-log",
  )
  go_repository(
      name = "com_github_ipfs_go_metrics_interface",
      commit = "6fb12c07d09b5db635a47107cf53c867228c7086",
      importpath = "github.com/ipfs/go-metrics-interface",
  )
  go_repository(
      name = "com_github_ipfs_go_metrics_prometheus",
      commit = "c3c0ab1359670984f5a9f9178bf55666fc9f3503",
      importpath = "github.com/ipfs/go-metrics-prometheus",
  )
  go_repository(
      name = "com_github_ipfs_go_todocounter",
      commit = "1e832b829506383050e6eebd12e05ea41a451532",
      importpath = "github.com/ipfs/go-todocounter",
  )
  go_repository(
      name = "com_github_jackpal_gateway",
      commit = "5795ac81146e01d3fab7bcf21c043c3d6a32b006",
      importpath = "github.com/jackpal/gateway",
  )
  go_repository(
      name = "com_github_jackpal_go_nat_pmp",
      commit = "28a68d0c24adce1da43f8df6a57340909ecd7fdd",
      importpath = "github.com/jackpal/go-nat-pmp",
  )
  go_repository(
      name = "com_github_jbenet_go_base58",
      commit = "6237cf65f3a6f7111cd8a42be3590df99a66bc7d",
      importpath = "github.com/jbenet/go-base58",
  )
  go_repository(
      name = "com_github_jbenet_go_context",
      commit = "d14ea06fba99483203c19d92cfcd13ebe73135f4",
      importpath = "github.com/jbenet/go-context",
  )
  go_repository(
      name = "com_github_jbenet_go_is_domain",
      commit = "ba9815c809e0dc052e170d8a8920c4636a819977",
      importpath = "github.com/jbenet/go-is-domain",
  )
  go_repository(
      name = "com_github_jbenet_go_msgio",
      commit = "242a3f4ed2d0098bff2f25b1bd32f4254e803b23",
      importpath = "github.com/jbenet/go-msgio",
  )
  go_repository(
      name = "com_github_jbenet_go_os_rename",
      commit = "3ac97f61ef67a6b87b95c1282f6c317ed0e693c2",
      importpath = "github.com/jbenet/go-os-rename",
  )
  go_repository(
      name = "com_github_jbenet_go_reuseport",
      commit = "8d25e8092505764dd381e2e19e6e8c6313e88a61",
      importpath = "github.com/jbenet/go-reuseport",
  )
  go_repository(
      name = "com_github_jbenet_go_sockaddr",
      commit = "2e7ea655c10e4d4d73365f0f073b81b39cb08ee1",
      importpath = "github.com/jbenet/go-sockaddr",
  )
  go_repository(
      name = "com_github_jbenet_go_stream_muxer",
      commit = "829afa06d6d9f2afb24a02dba841fa9b57390b6c",
      importpath = "github.com/jbenet/go-stream-muxer",
  )
  go_repository(
      name = "com_github_jbenet_go_temp_err_catcher",
      commit = "aac704a3f4f27190b4ccc05f303a4931fd1241ff",
      importpath = "github.com/jbenet/go-temp-err-catcher",
  )
  go_repository(
      name = "com_github_jbenet_goprocess",
      commit = "b497e2f366b8624394fb2e89c10ab607bebdde0b",
      importpath = "github.com/jbenet/goprocess",
  )
  go_repository(
      name = "com_github_kr_fs",
      commit = "2788f0dbd16903de03cb8186e5c7d97b69ad387b",
      importpath = "github.com/kr/fs",
  )
  go_repository(
      name = "com_github_libp2p_go_addr_util",
      commit = "8c03d78e8434dac314ae5148070b8f8c046dcd1d",
      importpath = "github.com/libp2p/go-addr-util",
  )
  go_repository(
      name = "com_github_libp2p_go_floodsub",
      commit = "9a5851c0f6a4cee0dcda0fcf8d8ff911091f2c3b",
      importpath = "github.com/libp2p/go-floodsub",
  )
  go_repository(
      name = "com_github_libp2p_go_libp2p",
      commit = "caa868349aed12d3c3f926d9e144ebf2bfd7682e",
      importpath = "github.com/libp2p/go-libp2p",
  )
  go_repository(
      name = "com_github_libp2p_go_libp2p_circuit",
      commit = "2bd4cf9d251078cd457c23427d9d9b39162f9ac9",
      importpath = "github.com/libp2p/go-libp2p-circuit",
  )
  go_repository(
      name = "com_github_libp2p_go_libp2p_conn",
      commit = "69dbe1bc13393880f3e3bae244d047194ca8e587",
      importpath = "github.com/libp2p/go-libp2p-conn",
  )
  go_repository(
      name = "com_github_libp2p_go_libp2p_connmgr",
      commit = "acd272c2af60acbb1bd02d8ffa725cc384a56397",
      importpath = "github.com/libp2p/go-libp2p-connmgr",
  )
  go_repository(
      name = "com_github_libp2p_go_libp2p_crypto",
      commit = "e89e1de117dd65c6129d99d1d853f48bc847cf17",
      importpath = "github.com/libp2p/go-libp2p-crypto",
  )
  go_repository(
      name = "com_github_libp2p_go_libp2p_host",
      commit = "80284432e5746b66d28f959239b0355c74c58662",
      importpath = "github.com/libp2p/go-libp2p-host",
  )
  go_repository(
      name = "com_github_libp2p_go_libp2p_interface_conn",
      commit = "b3243beaa4d5ee07591b5b3e0a0f18e37b61b8f9",
      importpath = "github.com/libp2p/go-libp2p-interface-conn",
  )
  go_repository(
      name = "com_github_libp2p_go_libp2p_interface_pnet",
      commit = "28cd03f4a907f498f60a56a20de93320dc0b68c3",
      importpath = "github.com/libp2p/go-libp2p-interface-pnet",
  )
  go_repository(
      name = "com_github_libp2p_go_libp2p_kad_dht",
      commit = "2c0f26f0936cec7de931bce96645b2ad8c6d9b7e",
      importpath = "github.com/libp2p/go-libp2p-kad-dht",
  )
  go_repository(
      name = "com_github_libp2p_go_libp2p_kbucket",
      commit = "a45dd389b6d11f4a75c8f14fe58219932027d85c",
      importpath = "github.com/libp2p/go-libp2p-kbucket",
  )
  go_repository(
      name = "com_github_libp2p_go_libp2p_loggables",
      commit = "bb8a0d998a5284b1ccbcea9dc07c2abe66d6451b",
      importpath = "github.com/libp2p/go-libp2p-loggables",
  )
  go_repository(
      name = "com_github_libp2p_go_libp2p_metrics",
      commit = "96353bf81b1e948656ba000cec067d688831e000",
      importpath = "github.com/libp2p/go-libp2p-metrics",
  )
  go_repository(
      name = "com_github_libp2p_go_libp2p_nat",
      commit = "9e4c905f5516e03f855f6fbd9e5e89823884d880",
      importpath = "github.com/libp2p/go-libp2p-nat",
  )
  go_repository(
      name = "com_github_libp2p_go_libp2p_net",
      commit = "61a09c8234f639c70daa5f881e79b4fc1366a40e",
      importpath = "github.com/libp2p/go-libp2p-net",
  )
  go_repository(
      name = "com_github_libp2p_go_libp2p_netutil",
      commit = "9583dd4c4577d58da4b310ba78b742e746bf2b9f",
      importpath = "github.com/libp2p/go-libp2p-netutil",
  )
  go_repository(
      name = "com_github_libp2p_go_libp2p_peer",
      commit = "d863b451638c441d046c53834ccfef13beebd025",
      importpath = "github.com/libp2p/go-libp2p-peer",
  )
  go_repository(
      name = "com_github_libp2p_go_libp2p_peerstore",
      commit = "b2087a91b1d6f5f0c4477c71a51a32eb68a8c685",
      importpath = "github.com/libp2p/go-libp2p-peerstore",
  )
  go_repository(
      name = "com_github_libp2p_go_libp2p_pnet",
      commit = "ca4a3c5aa97baf29d47d72d76db6a3c9c84ca37e",
      importpath = "github.com/libp2p/go-libp2p-pnet",
  )
  go_repository(
      name = "com_github_libp2p_go_libp2p_protocol",
      commit = "40488c03777c16bfcd65da2f675b192863cbc2dc",
      importpath = "github.com/libp2p/go-libp2p-protocol",
  )
  go_repository(
      name = "com_github_libp2p_go_libp2p_record",
      commit = "829c054bf734caa5046bda8c3b4a6bdde2e9c595",
      importpath = "github.com/libp2p/go-libp2p-record",
  )
  go_repository(
      name = "com_github_libp2p_go_libp2p_routing",
      commit = "71b44923324ed1a196407aee679cdf749194fb05",
      importpath = "github.com/libp2p/go-libp2p-routing",
  )
  go_repository(
      name = "com_github_libp2p_go_libp2p_secio",
      commit = "59400d5311f58f959ce2ebeb10a5e1d0deb6e7e5",
      importpath = "github.com/libp2p/go-libp2p-secio",
  )
  go_repository(
      name = "com_github_libp2p_go_libp2p_swarm",
      commit = "f391ed198b648985efddd4e50a79ebd5f476ec1a",
      importpath = "github.com/libp2p/go-libp2p-swarm",
  )
  go_repository(
      name = "com_github_libp2p_go_libp2p_transport",
      commit = "1b7d004fdc7582bf3ed714b187a8294e71cf824b",
      importpath = "github.com/libp2p/go-libp2p-transport",
  )
  go_repository(
      name = "com_github_libp2p_go_maddr_filter",
      commit = "ac6a10c4e30dabf1a55aa0f51102ae4daed951fb",
      importpath = "github.com/libp2p/go-maddr-filter",
  )
  go_repository(
      name = "com_github_libp2p_go_peerstream",
      commit = "c15fff8170cd6df69c5a5716e9f59d344ceab1e2",
      importpath = "github.com/libp2p/go-peerstream",
  )
  go_repository(
      name = "com_github_libp2p_go_stream_muxer",
      commit = "f70d5fb361c74d37a98c736c9658adc1e8c4b190",
      importpath = "github.com/libp2p/go-stream-muxer",
  )
  go_repository(
      name = "com_github_libp2p_go_tcp_transport",
      commit = "ddf1eb06c937376a63c6fbfa628d9ba6e31e51be",
      importpath = "github.com/libp2p/go-tcp-transport",
  )
  go_repository(
      name = "com_github_libp2p_go_testutil",
      commit = "74cb0006b15788e0d6c2525eafdb8531ae921490",
      importpath = "github.com/libp2p/go-testutil",
  )
  go_repository(
      name = "com_github_libp2p_go_ws_transport",
      commit = "f2fb5ceb7d24bce04afd738441c7efc854a543f1",
      importpath = "github.com/libp2p/go-ws-transport",
  )
  go_repository(
      name = "com_github_mattn_go_runewidth",
      commit = "97311d9f7767e3d6f422ea06661bc2c7a19e8a5d",
      importpath = "github.com/mattn/go-runewidth",
  )
  go_repository(
      name = "com_github_matttproud_golang_protobuf_extensions",
      commit = "c12348ce28de40eed0136aa2b644d0ee0650e56c",
      importpath = "github.com/matttproud/golang_protobuf_extensions",
  )
  go_repository(
      name = "com_github_miekg_dns",
      commit = "e4205768578dc90c2669e75a2f8a8bf77e3083a4",
      importpath = "github.com/miekg/dns",
  )
  go_repository(
      name = "com_github_mitchellh_go_homedir",
      commit = "b8bc1bf767474819792c23f32d8286a45736f1c6",
      importpath = "github.com/mitchellh/go-homedir",
  )
  go_repository(
      name = "com_github_multiformats_go_multiaddr",
      commit = "6addc7f583980ebb06b33b5c24b703b245c6984f",
      importpath = "github.com/multiformats/go-multiaddr",
  )
  go_repository(
      name = "com_github_multiformats_go_multiaddr_dns",
      commit = "d974dec81f5fcad4c29a427d327afb5bc6c0f39a",
      importpath = "github.com/multiformats/go-multiaddr-dns",
  )
  go_repository(
      name = "com_github_multiformats_go_multiaddr_net",
      commit = "376ba58703c84bfff9ca6e0057adf38ad48d3de5",
      importpath = "github.com/multiformats/go-multiaddr-net",
  )
  go_repository(
      name = "com_github_multiformats_go_multibase",
      commit = "af68ad2dd723b6b513b17b5271da9dcd5f5949b7",
      importpath = "github.com/multiformats/go-multibase",
  )
  go_repository(
      name = "com_github_multiformats_go_multicodec",
      commit = "5e2f2923465fed1fd86110f37ca1a64ba1c0e55d",
      importpath = "github.com/multiformats/go-multicodec",
  )
  go_repository(
      name = "com_github_multiformats_go_multicodec_packed",
      commit = "0ee69486dc1c9087aacfcc575e333f305009997e",
      importpath = "github.com/multiformats/go-multicodec-packed",
  )
  go_repository(
      name = "com_github_multiformats_go_multihash",
      commit = "f1ef5a02f28c862ca5a2037907cf76cc6c98dbf9",
      importpath = "github.com/multiformats/go-multihash",
  )
  go_repository(
      name = "com_github_multiformats_go_multistream",
      commit = "b8f1996688ab586031517919b49b1967fca8d5d9",
      importpath = "github.com/multiformats/go-multistream",
  )
  go_repository(
      name = "com_github_prometheus_client_model",
      commit = "6f3806018612930941127f2a7c6c453ba2c527d2",
      importpath = "github.com/prometheus/client_model",
  )
  go_repository(
      name = "com_github_prometheus_common",
      commit = "61f87aac8082fa8c3c5655c7608d7478d46ac2ad",
      importpath = "github.com/prometheus/common",
  )
  go_repository(
      name = "com_github_prometheus_procfs",
      commit = "e645f4e5aaa8506fc71d6edbc5c4ff02c04c46f2",
      importpath = "github.com/prometheus/procfs",
  )
  go_repository(
      name = "com_github_rs_cors",
      commit = "eabcc6af4bbe5ad3a949d36450326a2b0b9894b8",
      importpath = "github.com/rs/cors",
  )
  go_repository(
      name = "com_github_sabhiram_go_git_ignore",
      commit = "730f0220149475811d197e7905f73b3eadd28f4b",
      importpath = "github.com/sabhiram/go-git-ignore",
  )
  go_repository(
      name = "com_github_satori_go_uuid",
      commit = "5bf94b69c6b68ee1b541973bb8e1144db23a194b",
      importpath = "github.com/satori/go.uuid",
  )
  go_repository(
      name = "com_github_spaolacci_murmur3",
      commit = "9f5d223c60793748f04a9d5b4b4eacddfc1f755d",
      importpath = "github.com/spaolacci/murmur3",
  )
  go_repository(
      name = "com_github_steakknife_hamming",
      commit = "5ac3f73b8842df21423978fbbeb5166670f6f73e",
      importpath = "github.com/steakknife/hamming",
  )
  go_repository(
      name = "com_github_syndtr_goleveldb",
      commit = "b89cc31ef7977104127d34c1bd31ebd1a9db2199",
      importpath = "github.com/syndtr/goleveldb",
  )
  go_repository(
      name = "com_github_whyrusleeping_autobatch",
      commit = "055ea5cded491803066f8aac4a0f4fce2ca0ec6b",
      importpath = "github.com/whyrusleeping/autobatch",
  )
  go_repository(
      name = "com_github_whyrusleeping_base32",
      commit = "040256406660c57e043d6cc8a9406d20c4fc7277",
      importpath = "github.com/whyrusleeping/base32",
  )
  go_repository(
      name = "com_github_whyrusleeping_cbor",
      commit = "1f7eb02d86d710f364f892f37649f091865a2441",
      importpath = "github.com/whyrusleeping/cbor",
  )
  go_repository(
      name = "com_github_whyrusleeping_go_keyspace",
      commit = "5b898ac5add1da7178a4a98e69cb7b9205c085ee",
      importpath = "github.com/whyrusleeping/go-keyspace",
  )
  go_repository(
      name = "com_github_whyrusleeping_go_logging",
      commit = "0457bb6b88fc1973573aaf6b5145d8d3ae972390",
      importpath = "github.com/whyrusleeping/go-logging",
  )
  go_repository(
      name = "com_github_whyrusleeping_go_metrics",
      commit = "1ca5caed0cfa95a47fd65a79762286ae626c865c",
      importpath = "github.com/whyrusleeping/go-metrics",
  )
  go_repository(
      name = "com_github_whyrusleeping_go_multipart_files",
      commit = "3be93d9f6b618f2b8564bfb1d22f1e744eabbae2",
      importpath = "github.com/whyrusleeping/go-multipart-files",
  )
  go_repository(
      name = "com_github_whyrusleeping_go_multiplex",
      commit = "b5f9a1c97b1d4fc24fec82b316a6cf7ebff0da25",
      importpath = "github.com/whyrusleeping/go-multiplex",
  )
  go_repository(
      name = "com_github_whyrusleeping_go_smux_multiplex",
      commit = "04546180529e209aaa4d1b9d963b9199ece09af8",
      importpath = "github.com/whyrusleeping/go-smux-multiplex",
  )
  go_repository(
      name = "com_github_whyrusleeping_go_smux_multistream",
      commit = "a8f6f9a46f04c6c944000c59a0d06a767e75ae3a",
      importpath = "github.com/whyrusleeping/go-smux-multistream",
  )
  go_repository(
      name = "com_github_whyrusleeping_go_smux_spdystream",
      commit = "99ef171dcd9ac9c7324f49c11cc22fc088eb2552",
      importpath = "github.com/whyrusleeping/go-smux-spdystream",
  )
  go_repository(
      name = "com_github_whyrusleeping_go_smux_yamux",
      commit = "c6704f34736883e7ab16087389d0744b07874821",
      importpath = "github.com/whyrusleeping/go-smux-yamux",
  )
  go_repository(
      name = "com_github_whyrusleeping_go_sysinfo",
      commit = "dee6add16c7d185abf829c6ba08983fcc3bc5b99",
      importpath = "github.com/whyrusleeping/go-sysinfo",
  )
  go_repository(
      name = "com_github_whyrusleeping_gx",
      commit = "4dee4600829c587123523cc5d9d38b95ff7a7c12",
      importpath = "github.com/whyrusleeping/gx",
  )
  go_repository(
      name = "com_github_whyrusleeping_gx_go",
      commit = "a1405aae0a8444ccbfd3990585b82375c90e2ebb",
      importpath = "github.com/whyrusleeping/gx-go",
  )
  go_repository(
      name = "com_github_whyrusleeping_json_filter",
      commit = "ff25329a9528f01c5175414f16cc0a6a162a5b8b",
      importpath = "github.com/whyrusleeping/json-filter",
  )
  go_repository(
      name = "com_github_whyrusleeping_mafmt",
      commit = "8eaabeb0013fb995358b239e04394c27acaf38a2",
      importpath = "github.com/whyrusleeping/mafmt",
  )
  go_repository(
      name = "com_github_whyrusleeping_mdns",
      commit = "348bb87e5cd39b33dba9a33cb20802111e5ee029",
      importpath = "github.com/whyrusleeping/mdns",
  )
  go_repository(
      name = "com_github_whyrusleeping_multiaddr_filter",
      commit = "e903e4adabd70b78bc9293b6ee4f359afb3f9f59",
      importpath = "github.com/whyrusleeping/multiaddr-filter",
  )
  go_repository(
      name = "com_github_whyrusleeping_progmeter",
      commit = "974d8fe8cd87585865b1370184050e89d606e817",
      importpath = "github.com/whyrusleeping/progmeter",
  )
  go_repository(
      name = "com_github_whyrusleeping_retry_datastore",
      commit = "a719db2f1ec40bc493de11f70b27e357dc74e0a9",
      importpath = "github.com/whyrusleeping/retry-datastore",
  )
  go_repository(
      name = "com_github_whyrusleeping_stump",
      commit = "206f8f13aae1697a6fc1f4a55799faf955971fc5",
      importpath = "github.com/whyrusleeping/stump",
  )
  go_repository(
      name = "com_github_whyrusleeping_tar_utils",
      commit = "beab27159606f5a7c978268dd1c3b12a0f1de8a7",
      importpath = "github.com/whyrusleeping/tar-utils",
  )
  go_repository(
      name = "com_github_whyrusleeping_timecache",
      commit = "cfcb2f1abfee846c430233aef0b630a946e0a5a6",
      importpath = "github.com/whyrusleeping/timecache",
  )
  go_repository(
      name = "com_github_whyrusleeping_yamux",
      commit = "6ceb0c73fcc4344f89caa1b45572cb3d61c06a11",
      importpath = "github.com/whyrusleeping/yamux",
  )
  go_repository(
      name = "io_leb_hashland",
      commit = "e13accbe55f7fa03c73c74ace4cca4c425e47260",
      importpath = "leb.io/hashland",
  )
  go_repository(
      name = "org_bazil_fuse",
      commit = "d012caaaf81dbfcff8c1674fc026c8844d1ebcbe",
      importpath = "bazil.org/fuse",
      vcs = "git",
      remote = "https://github.com/gxed/bazil-fuse",
  )
  go_repository(
      name = "org_go4",
      commit = "034d17a462f7b2dcd1a4a73553ec5357ff6e6c6e",
      importpath = "go4.org",
  )
  go_repository(
      name = "org_golang_x_crypto",
      commit = "eb71ad9bd329b5ac0fd0148dd99bd62e8be8e035",
      importpath = "golang.org/x/crypto",
  )
  go_repository(
      name = "org_golang_x_net",
      commit = "1c05540f6879653db88113bc4a2b70aec4bd491f",
      importpath = "golang.org/x/net",
  )
  go_repository(
      name = "org_golang_x_sys",
      commit = "07c182904dbd53199946ba614a412c61d3c548f5",
      importpath = "golang.org/x/sys",
  )
  go_repository(
      name = "org_golang_x_text",
      commit = "e56139fd9c5bc7244c76116c68e500765bb6db6b",
      importpath = "golang.org/x/text",
  )
