function [resultImage, permuteParameter] = hb_imageScramble(inputImage, nSection, showOption)
% this matlab function returns scrambled matrix of input image, [nSection+1 by nSection+1] 
% example -> image scramble into 2 by 2 grid (without image plot)
% >> resultImage = hb_imageScramble(inputImage, 2, false);
% example -> image scramble into 4 by 4 grid (with image plot)
% >> resultImage = hb_imageScramble(inputImage, 4, true);
% initial commit : 20160326
% hiobeen@yonsei.ac.kr
% key word : image scramble matlab 

if nargin < 3
    showOption = false;
end
if nSection == 1
    resultImage = inputImage; 
    if showOption
        subplot(1,2,1); imshow(inputImage); title('input image'); 
        subplot(1,2,2); imshow(resultImage); title(['scrambled image (' num2str(nSection) ' by ' num2str(nSection) ')']); 
    end
    return;
end
[nRow, nCol, nDim] = size(inputImage);

rowSpace = floor(linspace( 1, nRow , nSection+1 )); % make mosaic indicies
colSpace  = floor(linspace( 1, nCol , nSection+1 )); 

rowSpace(end) = nRow; colSpace(end) = nCol; % should be equal to original image size
min_possibleSize = [ max(diff(rowSpace)), max(diff(colSpace)) ]; 

mosaics = cell([1,(nSection)^2]); % section images into {N x N}, and temporally store into the cell 'mosaics'
permuteParameter = randperm( (nSection)^2 ); % make random indexing parameter

% Split image into cells (with random order)
mosaic_nAppend = 0;
for rowIdx = 1:length(rowSpace)-1
    for colIdx = 1:length(rowSpace)-1
        mosaic_nAppend = mosaic_nAppend+1;
        mosaics{1,permuteParameter(mosaic_nAppend)} = imresize(inputImage(...
            rowSpace(rowIdx):rowSpace(rowIdx+1)-1,...
            colSpace(colIdx):colSpace(colIdx+1)-1, :), min_possibleSize);
    end
end

% CAT image, step 1 (integrate by rows)
cat_row = cell( [1, nSection] );
cat_row_nAppend = 0;
for cellIdx = 1:length(mosaics)
    if mod(cellIdx, nSection) == 1
        cat_row_nAppend = cat_row_nAppend+1;
    end
    cat_row{1, cat_row_nAppend} = cat(1,cat_row{1, cat_row_nAppend},...
        mosaics{1,cellIdx});
end

% CAT image, step 2 (integrate by columns)
cat_col = [];
for cellIdx = 1:length(cat_row)
    cat_col = cat(2, cat_col, cat_row{1,cellIdx});
end

% CAT image, step 3 (integrate by color dimension)
if nDim > 1
    resultImage = [];
    for dimIdx = 1:nDim
        resultImage = cat(3, resultImage, imresize(squeeze(cat_col(:,:,dimIdx)), [nRow, nCol]));
    end
else
    resultImage = imresize(cat_col, [nRow, nCol]);
end

if showOption
    subplot(1,2,1); imshow(inputImage); title('input image');
    set(gca, 'YDir', 'normal');
    subplot(1,2,2); imshow(resultImage); title(['scrambled image (' num2str(nSection) ' by ' num2str(nSection) ')']);
    set(gca, 'YDir', 'normal');
end

return
