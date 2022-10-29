
#lang racket


;; for testing purposes pull in json
(require json)
(require database-url)


;; db connection pool
;; https://docs.racket-lang.org/db/using-db.html

;; DB: Database Connectivity - https://docs.racket-lang.org/db/index.html
(require db)

;; database authentication ~/.pgpass
;; 

;; postgres refresher psql starts postgres prompt
;; psql
;; \l
;; \c my_bookshop
;; \dt


;; define postgres connection pgc
;; using connection pool
(define db-conn
  (virtual-connection
   (connection-pool
    (lambda () 
      (postgresql-connect       
       (database-url-parse (getenv "DATABASE_URL")))))))





;; for effect query-exec
;; (query-exec pgc
;;     "insert into the_numbers values ($1, $2)"
;;     (+ 1 1)
;;     "company")


;; more general query 
;; (query pgc "insert into the_numbers values (3, 'a crowd')")


;; =========== one specific row ===================
(define query-specific-row->json
  (lambda  (row)
    (let ((do-not-reorder-headers '(id name fact)))
      (make-hasheq (list  (cons (list-ref do-not-reorder-headers 0) (vector-ref row 0))
			  (cons (list-ref do-not-reorder-headers 1) (vector-ref row 1))
			  (cons (list-ref do-not-reorder-headers 2) (vector-ref row 2)))))))



;;
;; drracket db query returns #( 1 , "Dan Brown" "Favourite colour is not brown")
;; which is a racket vector
;;
;; not acceptable by json
;; 
;;
;; when get rows wanted query-rows
;;
;; write-json : jsexpr -> json
;;========== multiple rows but only one row really ===================
(define select-authors
  (lambda () 
    (let ((rows (query-rows db-conn "select * from authors;")))
      (map query-specific-row->json rows))))


;;========== multiple rows but only one row really ===================
(define select-author
  (lambda (p) 
    (let ((row (query-row db-conn "select * from authors where id = $1" p)))
      (query-specific-row->json row))))





;; (let ((rows (query-rows db-conn "select * from authors;")))
;;   (with-output-to-string
;;     (lambda () (write-json (map query-specific-row->json rows)))))


;; (make-hasheq (list (cons 'authors 

;; (let ((rows (query-rows db-conn "select * from authors;")))
;;   (jsexpr? (map query-specific-row->json rows))
;;   rows)

;;========== multiple rows but only one row really ===================
(let ((row (query-rows db-conn "select * from authors where id = 1 ;")))
  (jsexpr?  row)
  row)


;; expect only one result
(let ((row (query-row db-conn "select * from authors where id = 1 ;")))
  (jsexpr?  row)
  (vector?  row)
  (jsexpr?  (query-specific-row->json row))
  (query-specific-row->json row))


;; one row
;;(query-row db-conn "select * from authors where id = 1;")

;; done with connection
;;(disconnect pgc)

((lambda () 
   #hasheq(( id . 1) (name . "Dan Brown") (fact . "Favourite colour is not brown"))))



;; racket module system
;; provide
(provide db-conn
	 select-authors
	 select-author)
