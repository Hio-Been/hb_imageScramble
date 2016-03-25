function [resultImage, permuteParameter] = hb_imageScramble(inputImage, nSection, showOption)
% this matlab function returns scrambled matrix of input image, [nSection+1 by nSection+1] 
% example -> image scramble into 2 by 2 grid (without image plot)
% >> resultImage = hb_imageScramble(inputImage, 2, false);
% example -> image scramble into 4 by 4 grid (with image plot)
% >> resultImage = hb_imageScramble(inputImage, 4, true);
% initial commit : 20160326
% hiobeen@yonsei.ac.kr

if nargin < 3
    showOption = false;
end
if nSection == 1
    resultImage = inputImage; 
    if showOption
        subplot(2,1,1); imshow(inputImage); title('input image');
        subplot(2,1,2); imshow(resultImage); title('result image');
    end
    return;
end
[nRow, nCol, nDim] = size(inputImage);

rowSpace = floor(linspace( 1, nRow , nSection+1 ));
colSpace  = floor(linspace( 1, nCol , nSection+1 ));
min_possibleSize = [ max(diff(rowSpace)), max(diff(colSpace)) ];

rowSpace(end) = nRow; colSpace(end) = nCol;

tempCell = cell([1,(nSection)^2]);
permuteParameter = randperm( (nSection)^2 );

% Split image into cells (with random order)
nAppend = 0;
for rowIdx = 1:length(rowSpace)-1
    for colIdx = 1:length(rowSpace)-1
        nAppend = nAppend+1;
        tempCell{1,permuteParameter(nAppend)} = imresize(inputImage(...
            rowSpace(rowIdx):rowSpace(rowIdx+1)-1,...
            colSpace(colIdx):colSpace(colIdx+1)-1, :), min_possibleSize);
    end
end

% CAT image, step 1 (integrate by rows)
cat_row = cell( [1, nSection] );
cat_row_nAppend = 0;
for cellIdx = 1:length(tempCell)
    if mod(cellIdx, nSection) == 1
        cat_row_nAppend = cat_row_nAppend+1;
    end
    cat_row{1, cat_row_nAppend} = cat(1,cat_row{1, cat_row_nAppend},...
        tempCell{1,cellIdx});
end

% CAT image, step 2 (integrate by columns)
cat_col = [];
for cellIdx = 1:length(cat_row)
    cat_col = cat(2, cat_col, cat_row{1,cellIdx});
end
if nDim > 1
    resultImage = imresize(cat_col, [nRow, nCol, nDim]);
else
    resultImage = imresize(cat_col, [nRow, nCol]);
end

if showOption
    subplot(1,2,1); imshow(inputImage); title('input image');
    subplot(1,2,2); imshow(resultImage); title('scrambled image');
end

return
