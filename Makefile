all: test

test: docker.ml
	ocamlbuild -r -use-ocamlfind -package lwt,cohttp,cohttp.lwt,yojson docker.native

clean:
	rm -fr _build *.native *.cmi *.cmo *.annot *~