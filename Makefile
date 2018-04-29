work_dir=build_work
out_dir=ISO_Image

all:
	@rm -rf ${work_dir} ${ISO_Image}
	@./build.sh -v
iso:
	@rm -rf ${work_dir} ${ISO_Image}
	@./build.sh -v
clean:
	@rm -rfv ${work_dir} ${out_dir}
	@echo "Cleaned"
