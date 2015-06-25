all: test

test: docker.ml
	ocamlbuild -r -use-ocamlfind -package cohttp docker.native

clean:
	rm -fr _build *.native *.cmi *.cmo *.annot *~