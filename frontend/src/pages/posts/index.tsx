import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/router';
import Layout from '../../components/Layout';
import ProtectedRoute from '../../components/ProtectedRoute';
import api from '../../lib/api';

interface Post {
  id: number;
  title: string;
  content: string;
  published: boolean;
  fileUrl?: string;
  createdAt: string;
  author: {
    name: string;
  };
}

const PostsList: React.FC = () => {
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(0);
  const [limit] = useState(10);
  const router = useRouter();

  useEffect(() => {
    fetchPosts();
  }, [page, search]);

  const fetchPosts = async () => {
    try {
      setLoading(true);
      const response = await api.get('/posts', {
        params: { page, limit, search: search || undefined },
      });
      setPosts(response.data.posts || []);
      setTotal(response.data.total || 0);
    } catch (error) {
      console.error('Error fetching posts:', error);
      setPosts([]);
      setTotal(0);
    } finally {
      setLoading(false);
    }
  };

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setPage(1);
    fetchPosts();
  };

  const totalPages = Math.ceil(total / limit);

  return (
    <ProtectedRoute>
      <Layout>
        <div className="px-4 py-6">
          <div className="flex justify-between items-center mb-6">
            <h1 className="text-3xl font-bold text-gray-900">Posts</h1>
            <Link
              href="/posts/new"
              className="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded-md"
            >
              Create New Post
            </Link>
          </div>

          <form onSubmit={handleSearchSubmit} className="mb-6">
            <div className="flex gap-2">
              <input
                type="text"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Search posts..."
                className="flex-1 px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <button
                type="submit"
                className="bg-gray-700 hover:bg-gray-800 text-white px-6 py-2 rounded-md"
              >
                Search
              </button>
            </div>
          </form>

          {loading ? (
            <div className="text-center py-8">Loading posts...</div>
          ) : !posts || posts.length === 0 ? (
            <div className="text-center py-8 text-gray-500">
              No posts found. Create your first post!
            </div>
          ) : (
            <>
              <div className="space-y-4">
                {posts.map((post) => (
                  <div
                    key={post.id}
                    className="bg-white shadow rounded-lg p-6 hover:shadow-md transition-shadow cursor-pointer"
                    onClick={() => router.push(`/posts/${post.id}`)}
                  >
                    <div className="flex gap-4">
                      {post.fileUrl && (
                        <div className="flex-shrink-0">
                          {post.fileUrl.match(/\.(jpg|jpeg|png|gif)$/i) ? (
                            <img
                              src={post.fileUrl}
                              alt={post.title}
                              className="w-32 h-32 object-cover rounded-lg border border-gray-200"
                              onError={(e) => {
                                // Show placeholder on error
                                e.currentTarget.src = 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="128" height="128"%3E%3Crect fill="%23f3f4f6" width="128" height="128"/%3E%3Ctext fill="%23999" font-size="14" x="50%25" y="50%25" text-anchor="middle" dy=".3em"%3ENo Image%3C/text%3E%3C/svg%3E';
                              }}
                            />
                          ) : (
                            <div className="w-32 h-32 bg-gray-100 rounded-lg flex items-center justify-center border border-gray-200">
                              <svg className="w-12 h-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
                              </svg>
                            </div>
                          )}
                        </div>
                      )}
                      <div className="flex-1">
                        <h2 className="text-xl font-semibold text-gray-900 mb-2">
                          {post.title}
                        </h2>
                        <p className="text-gray-600 line-clamp-2">
                          {post.content}
                        </p>
                        <div className="mt-3 flex items-center text-sm text-gray-500">
                          <span>By {post.author.name}</span>
                          <span className="mx-2">•</span>
                          <span>
                            {new Date(post.createdAt).toLocaleDateString()}
                          </span>
                          {!post.published && (
                            <>
                              <span className="mx-2">•</span>
                              <span className="text-yellow-600 font-medium">
                                Draft
                              </span>
                            </>
                          )}
                          {post.fileUrl && (
                            <>
                              <span className="mx-2">•</span>
                              <a
                                href={post.fileUrl}
                                target="_blank"
                                rel="noopener noreferrer"
                                className="text-blue-600 hover:text-blue-800 hover:underline"
                                onClick={(e) => e.stopPropagation()}
                              >
                                📎 Has attachment
                              </a>
                            </>
                          )}
                        </div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>

              {/* Pagination */}
              {totalPages > 1 && (
                <div className="mt-6 flex justify-center gap-2">
                  <button
                    onClick={() => setPage((p) => Math.max(1, p - 1))}
                    disabled={page === 1}
                    className="px-4 py-2 border border-gray-300 rounded-md disabled:opacity-50"
                  >
                    Previous
                  </button>
                  <span className="px-4 py-2">
                    Page {page} of {totalPages}
                  </span>
                  <button
                    onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                    disabled={page === totalPages}
                    className="px-4 py-2 border border-gray-300 rounded-md disabled:opacity-50"
                  >
                    Next
                  </button>
                </div>
              )}
            </>
          )}
        </div>
      </Layout>
    </ProtectedRoute>
  );
};

export default PostsList;
