;;; move-ts-mode --- Major mode for Move with native treesit support -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(when (not (featurep 'move-mode))
  (error "Require feature 'move-mode"))
(when (not (and (functionp 'treesit-available-p) (treesit-available-p)))
  (error "Require Emacs >= 29 with --with-treesit"))


(define-derived-mode move-ts-mode move-mode "Move[Ts]"
  "..."
  :syntax-table nil
  (setq-local font-lock-defaults nil)
  (when (treesit-ready-p 'move)
    (treesit-parser-create 'move)
    (move-ts-setup)))

(defvar move-ts-font-lock-rules
  '(
    :language move
    :override t
    :feature types
    ((primitive_type) @font-lock-builtin-face
     (type_parameters) @font-lock-type-face
     (type_parameter) @font-lock-type-face
     (type_parameter_identifier) @font-lock-type-face
     (apply_type) @font-lock-type-face
     (ref_type) @font-lock-type-face)

    :language move
    :override t
    :feature keywords
    (
     [
      "fun"
      "return"
      "if"
      "else"
      "while"
      "native"
      "struct"
      "use"
      "public"
      "package"
      "spec"
      "module"
      "abort"
      "const"
      "let"
      "has"
      "as"
      "&"
      "friend"
      "entry"
      "mut"
      "macro"
      "enum"
      "break"
      "continue"
      "loop"]

     @font-lock-keyword-face)


    :language move
    :override t
    :feature consts
    (
     (constant name: (constant_identifier)  @font-lock-constant-face)
     (constant expr: (num_literal) @font-lock-constant-face))
    ;; ((identifier)
    ;;  (:match?  "^[A-Z][A-Z\\d_]+$'" @font-lock-constant-face)))


    :language move
    :override t
    :feature address_literals
    (
     (num_literal) @font-lock-number-face
     (bool_literal) @font-lock-string-face
     (hex_string_literal) @font-lock-string-face
     (byte_string_literal) @font-lock-string-face
     (address_literal) @font-lock-number-face)


    :language move
    :override t
    :feature abort_expression
    (
     (abort_expression) @font-lock-keyword-face)

    :language move
    :override t
    :feature mut_ref
    (
     (mut_ref) @font-lock-keyword-face)

    :language move
    :override t
    :feature comments
    (
     (line_comment) @font-lock-comment-face
     (block_comment) @font-lock-comment-face)


    :language move
    :override t
    :feature annotations
    (
     (annotation) @font-lock-preprocessor-face
     (annotation_item) @font-lock-preprocessor-face)


    :language move
    :override t
    :feature fun_definitions
    (
     ;; (function_identifier) @font-lock-function-name-face
     (function_definition name: (function_identifier)  @font-lock-function-name-face)
     (macro_function_definition name: (function_identifier)  @font-lock-function-name-face)
     (native_function_definition name: (function_identifier)  @font-lock-builtin-face)
     (usual_spec_function name: (function_identifier)  @font-lock-function-name-face)
     (function_parameter name: (variable_identifier)  @font-lock-variable-name-face))
    ;; (native_function_definition name: (function_identifier) @font-lock-function-name-face)
    ;; (usual_spec_function name: (function_identifier)  @font-lock-function-name-face)
    ;; (function_parameter name: (variable_identifier)  @font-lock-variable-name-face))


    :language move
    :override t
    :feature module_definitions
    (
     (module_identity address: (module_identifier)  @font-lock-constant-face)
     (module_identity module: (module_identifier)  @font-lock-preprocessor-face))


    :language move
    :override t
    :feature identifiers
    ((identifier) @font-lock-variable-use-face)
    ;;  ((module_access member: (identifier) @font-lock-function-call-face)))


    :language move
    :override t
    :feature function_calls
    (
     (call_expression (name_expression access: (module_access module: (module_identifier)  @font-lock-preprocessor-face)))
     (call_expression (name_expression access: (module_access member: (identifier)  @font-lock-function-call-face))))


    :language move
    :override t
    :feature macro_calls
    (
     (macro_call_expression access: (macro_module_access) @font-lock-function-call-face))

    ;; :language move
    ;; :override t
    ;; :feature uses
    ;; (
    ;;  (use_member member: (identifier)  @font-lock-preprocessor-face)
    ;;  (use_module alias: (module_identifier) @font-lock-preprocessor-face)
    ;;  (use_fun (module_access module: (module_identifier)  @font-lock-preprocessor-face))
    ;;  (use_fun (module_access member: (identifier)  @font-lock-preprocessor-face)))

    :language move
    :override t
    :feature labels
    (
     (label (identifier)  @font-lock-negation-char-face))


    :language move
    :override t
    :feature structs
    ((struct_definition name: (struct_identifier)  @font-lock-type-face)
     (ability) @font-lock-keyword-face
     (field_annotation field: (field_identifier)  @font-lock-property-name-face)
     (field_identifier) @font-lock-property-name-face)


    :language move
    :override t
    :feature enums
    (
     (enum_definition name: (enum_identifier)  @font-lock-type-face)
     (variant variant_name: (variant_identifier)  @font-lock-type-face))


    :language move
    :override t
    :feature packs
    (
     (pack_expression (name_expression access: (module_access)  @font-lock-type-face)))


    ;; :language move
    ;; :override t
    ;; :feature unpacks
    ;; ((module_access) @font-lock-type-face
    ;;  (module_access "$" (identifier)) @font-lock-variable-use-face
    ;;  ["$"] @font-lock-variable-use-face)


    :language move
    :override t
    :feature brackets
    (["("
      ")"
      "["
      "]"
      "{"
      "}"]
     @font-lock-bracket-face)


    :language move
    :override t
    :feature delimiters
    (["." ","] @font-lock-delimiter-face)


    :language move
    :override t
    :feature operators
    ([(binary_operator)
      (unary_op)
      "=>"
      "@"
      "->"]
     @font-lock-operator-face)


    :language move
    :override t
    :feature specs
    ([(spec_pragma) @font-lock-preprocessor-face
      (condition_kind) @font-lock-warning-face
      (condition_properties) @font-lock-preprocessor-face])))


(defun move-ts-setup ()
  "..."
  (setq-local treesit-font-lock-feature-list
              '(
                (types consts module_definitions)
                (fun_definitions structs enums identifiers keywords)
                (annotations function_calls macro_calls abort_expression mut_ref comments delimiters brackets)
                (labels)))


  (setq-local treesit-font-lock-settings
              (apply #'treesit-font-lock-rules move-ts-font-lock-rules))
  ;; (setq-local treesit-simple-indent-rules move-ts-indent-rules)
  (setq-local treesit-font-lock-level 3)
  (treesit-major-mode-setup))

(provide 'move-ts-mode)

;;; move-ts-mode.el ends here
