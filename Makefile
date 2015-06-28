all: test

test: docker.ml
	ocamlbuild -r -use-ocamlfind -tag thread -package lwt,cohttp,cohttp.lwt,cohttp.async,yojson test_docker.native

clean:
	rm -fr _build *.native *.cmi *.cmo *.annot *~