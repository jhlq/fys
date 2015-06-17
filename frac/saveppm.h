#include <fstream>

typedef struct {
	int width;
	int height;
	uint8_t *data;
	size_t size;
} ppm_image;

size_t ppm_save(ppm_image *img, FILE *outfile) {
    size_t n = 0;
    n += fprintf(outfile, "P6\n# THIS IS A COMMENT\n%d %d\n%d\n", 
                 img->width, img->height, 0xFF);
    n += fwrite(img->data, 1, img->width * img->height * 3, outfile);
    return n;
}
