function [V,F,N] = load_tobj(filename)
  % Reads a .obj mesh file and outputs the vertex and face list
  % assumes a 3D triangle mesh and ignores everything but:
  % v x y z and f i j k lines
  % Input:
  %  filename  string of obj file's path
  %
  % Output:
  %  V  number of vertices x 3 array of vertex positions
  %  F  number of faces x 3 array of face indices
  %
 
  vertex_index = 1;
  face_index = 1;
  vertexNormal_index = 1;
  fid = fopen(filename,'rt');
  line = fgets(fid);
  
  numVerts = 0;
  numFaces = 0;
  
  
  while (numVerts == 0) | (numFaces == 0)
      if numVerts == 0
          numVerts = sscanf(line,'# Vertices: %i');
          if isempty(numVerts) 
              numVerts = 0;
          end
      end
      if numFaces == 0
          numFaces = sscanf(line,'# Faces: %i');
          if isempty(numFaces) 
              numFaces = 0;
          end
      end
      line = fgets(fid);
  end
  
  wbHandle = waitbar(0,'Loading obj...');
  
  V = zeros(numVerts,3);
  F = zeros(numFaces,3);
  N = zeros(numVerts,3);
  
  while ~isempty(line) && line(1) ~= -1
      if length(line) < 2
          line = fgets(fid);
          continue;
      end
      switch line(1:2)
          case 'v '
              vertex = sscanf(line,'v %f %f %f');
              V(vertex_index,:) = vertex;
              vertex_index = vertex_index+1;
          case 'f '
              if sum(line=='/') > 0
                  face_long = sscanf(line,'f %d//%d %d//%d %d//%d');
                  face = face_long(1:2:end);
              else
                  face = sscanf(line,'f %d %d %d');
              end
              F(face_index,:) = face;
              face_index = face_index+1;
          case 'vn'
              norms = sscanf(line,'vn %d %d %d');
              N(vertexNormal_index,:) = norms;
              vertexNormal_index = vertexNormal_index + 1;
          otherwise
%               fprintf('Ignoring %s\n');
      end

    line = fgets(fid);
    
    if mod((vertex_index + vertexNormal_index + face_index),1000) == 0
        waitbar((vertex_index + vertexNormal_index + face_index) / (numVerts*2+numFaces), wbHandle);
    end
  end
  close(wbHandle);
  pause(0.001);
  fclose(fid);
end