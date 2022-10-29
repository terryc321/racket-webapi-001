

#lang racket


;; json provides jsexpr?
(require json)

(require web-server/servlet)
(require web-server/servlet-env)
(require web-server/dispatch)


(require db)
(require "database.rkt")

(define PORT (if (getenv "PORT")
                 (string->number (getenv "PORT"))
                 7070))


(define (parse-json-body req)
  (bytes->jsexpr (request-post-data/raw req)))

(define (get-hash-value h v)
  (hash-ref h v))

;; =========== handlers ===========
(define (get-values req)
  (response/jsexpr
   (hasheq 'values
	   '(1 2 3 ))))

(define (post-values req)
  (define get-property
    (curry get-hash-value (parse-json-body req)))

  (define x (string->number (get-property 'x)))
  (define y (string->number (get-property 'y)))

  (response/jsexpr
   (hasheq 'sum (+ x y))))


;;=================================================
;; 
(define (get-authors req)
  (response/jsexpr
   (select-authors)))


;; (query-rows db-conn "select * from authors")))

;;; request req comes first ,

;;; /authors/:integer/sanity 
(define (get-single-author req p)
  (response/jsexpr
   (select-author p)))



;; ============= routes ==============
(define-values (dispatch req)
  (dispatch-rules
   [("authors") #:method "get" get-authors]   
   [("authors" (integer-arg) "sanity") #:method "get" get-single-author]   
   [("values") #:method "get" get-values]
   [("values") #:method "post" post-values]
   [else (error "Route does not exist")]
   ))


;; run server with run.sh shell script 
(serve/servlet
 (lambda (req) (dispatch req))
 #:launch-browser? #f
 #:quit? #f
 #:port PORT
 #:servlet-path "/"
 #:listen-ip #f
 #:servlet-regexp #rx"")





